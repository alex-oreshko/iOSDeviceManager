
module IDM
  require "singleton"
  require "run_loop"

  def self.exit_status(key)
    case key
    when :success
      0
    when :failure
      1
    when :false
      2
    when :missing_arg
      3
    when :invalid_arg
      4
    when :internal_error
      5
    when :invalid_command
      6
    when :invalid_flag
      7
    when :device_not_found
      8
    when :no_signing_identity
      9
    else
      raise ArgumentError, "Expected a valid key; found #{key}"
    end
  end

  def self.shell(args, environment={})
    cmd = [Resources.instance.idm] + args
    RunLoop::Shell.run_shell_command(cmd, {log_cmd: true,
                                           timeout: 180,
                                           environment: environment})
  end

  class Resources
    include Singleton

    def project_dir
      @project_dir ||= File.expand_path(File.join(File.dirname(__FILE__), ".."))
    end

    def resources_dir
      @resources_dir ||= File.join(project_dir, "Tests", "Resources")
    end

    def idm
      @idm ||= File.join(project_dir, "Products", "iOSDeviceManager")
    end

    def tmp_dir(subdir=nil)
      @tmp_dir ||= File.join(project_dir, "tmp")
      if subdir
        dir = File.join(tmp_dir, subdir)
      else
        dir = @tmp_dir
      end
      FileUtils.mkdir_p(dir)
      dir
    end

    # Remove this.
    #
    # We want @tmp_dir be memoized to "${project_dir}/tmp"
    #
    # If we pass a subdir argument, we do not want the
    # tmp directory to _always_ be "${project_dir}/tmp/subdir"
    def tmpdir(subdir=nil)
      @tmpdir ||= begin
                    path = File.expand_path("tmp")
                    FileUtils.mkdir_p(path)
                    path
                  end

      if subdir
        dir = File.join(@tmpdir, subdir)
        FileUtils.rm_rf(dir)
      else
        dir = path
      end
      dir
    end

    def xcode
      RunLoop::Xcode.new
    end

    def simctl
      RunLoop::Simctl.new
    end

    def default_simulator
      # remove comment
      #
      #
      # Since we have tests that are running against
      # all Xcode paths we don't need to store udid
      # in instance variable. Instead we select a new
      # one for every Xcode path
      local_xcode = xcode
      sim_string = RunLoop::Core.default_simulator(local_xcode)
      simctl.simulators.detect do |sim|
        sim.instruments_identifier(local_xcode) == sim_string
      end
    end

    def random_iphone
      simctl.simulators.select do |sim|
        sim.name[/iPhone/] &&
          sim.version >= RunLoop::Version.new("10.0") &&
          sim.udid != default_simulator.udid
      end.sample
    end

    def instruments
      RunLoop::Instruments.new
    end

    # duplicate
    def physical_devices
      instruments.physical_devices.select do |device|
        device_compatible_with_xcode?(device, xcode)
      end
    end

    # duplicate?
    def physical_device_connected?
      !physical_devices.empty?
    end

    # duplicate?
    def physical_device
      return nil if !physical_device_connected?
      return physical_devices[0] if physical_devices.count == 1

      value = ENV["DEVICE_TARGET"]
      if value.nil? || value == ""
        raise(ArgumentError, %Q[
More than one physical device is connected.

Use DEVICE_TARGET={udid | device-name} or disconnect all but one device.
              ])
      end

      device = instruments.physical_devices.select do |elm|
        elm.udid == value || elm.name == value
      end

      return device if device

      raise(ArgumentError %Q[
More than one physical device is connected.

DEVICE_TARGET=#{value} but no matching device is connected.

# Compatible connected devices
            #{physical_devices}

If a device is connected, it is possible that its iOS version is not
compatible with the current Xcode version.

# Connected devices
            #{instruments.physical_devices}

            ])
    end

    def test_app(type)
      @test_app_hash ||= Hash.new
      return @test_app_hash[type] if @test_app_hash[type]

      case type
      when :arm
        source = File.join(resources_dir, "arm", "AppStub.app")
        target = File.join(tmp_dir("arm"), "AppStub.app")
      when :x86
        source = File.join(resources_dir, "sim", "AppStub.app")
        target = File.join(tmp_dir("sim"), "AppStub.app")
      when :ipa
        source = File.join(resources_dir, "arm", "AppStub.ipa")
        target = File.join(tmp_dir("arm"), "AppStub.ipa")
      else
        raise ArgumentError, "Expected :arm, :x86, or :ipa, found: #{type}"
      end

      FileUtils.rm_rf(target)
      FileUtils.cp_r(source, target)

      @test_app_hash[type] = target
      target
    end

    def second_test_app(type)
      @second_test_app_hash ||= Hash.new
      return @second_test_app_hash[type] if @second_test_app_hash[type]

      case type
      when :arm
        source = File.join(resources_dir, "arm", "AppStubDupe.app")
        target = File.join(tmp_dir("arm"), "AppStubDupe.app")
      when :x86
        source = File.join(resources_dir, "sim", "AppStubDupe.app")
        target = File.join(tmp_dir("sim"), "AppStubDupe.app")
      when :ipa
        source = File.join(resources_dir, "arm", "AppStubDupe.ipa")
        target = File.join(tmp_dir("arm"), "AppStubDupe.ipa")
      else
        raise ArgumentError, "Expected :arm, :x86, or :ipa, found: #{type}"
      end

      FileUtils.rm_rf(target)
      FileUtils.cp_r(source, target)

      @second_test_app_hash[type] = target
      target
    end

    def with_developer_dir(developer_dir, &block)
      original_developer_dir = ENV['DEVELOPER_DIR']
      begin
        ENV.delete('DEVELOPER_DIR')
        ENV['DEVELOPER_DIR'] = developer_dir
        RunLoop::Simctl.ensure_valid_core_simulator_service
        block.call
      ensure
        ENV['DEVELOPER_DIR'] = original_developer_dir
      end
    end

    def xcode_install_paths
      @xcode_install_paths ||= begin
                                 min_xcode_version = RunLoop::Version.new("8.3.3")
                                 Dir.glob('/Xcode/*/*.app/Contents/Developer').map do |path|
                                   xcode_version = path[/(\d+\.\d+(\.\d+)?)/]
                                   if RunLoop::Version.new(xcode_version) >= min_xcode_version
                                     path
                                   else
                                     nil
                                   end
                                 end
                               end.compact
    end

    def with_xcode_installations(&block)
      xcode_install_paths.each do |developer_directory|
        with_developer_dir(developer_directory) do
          # Maybe?
          RunLoop::Simctl.ensure_valid_core_simulator_service
          block.call
        end
      end
    end

    def physical_devices_for_testing
      instruments = RunLoop::Instruments.new
      xcode = instruments.xcode
      xcode_version = xcode.version

      instruments.physical_devices.select do |device|
        device.compatible_with_xcode_version?(xcode_version)
      end
    end

    def default_physical_device
      physical_devices_for_testing.first
    end

    def physical_device_attached?
      default_physical_device != nil
    end
  end
end
