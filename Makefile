
.PHONY: build
.PHONY: tests
.PHONY: frameworks
.PHONY: dependencies

clean:
	rm -rf build

build:
	bin/make/build.sh

dependencies:
	bin/make/dependencies.sh

frameworks:
	bin/make/frameworks.sh

unit-tests:
	bin/test/unit.sh

integration-tests:
	bin/test/integration.sh

cli-tests:
	bin/test/cli.sh

run-loop-tests:
	bin/test/run-loop.sh

tests:
	$(MAKE) unit-tests
	$(MAKE) integration-tests
	$(MAKE) cli-tests
	$(MAKE) run-loop-tests
