.PHONY: build

build:
	mkdir -p build
	cc -dynamiclib src/get_free_space.c -arch x86_64 -arch arm64 -o build/DiskSpacePlugin.dylib
