.PHONY: all test status clean release
all:
	./build.sh
test:
	./build.sh test
status:
	./build.sh status
clean:
	./clean.sh --deep
release:
	scripts/package-release.sh
