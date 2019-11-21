SENTRY_ORG=testorg-az
SENTRY_PROJECT=ido-sentry-native
#VERSION ?=`sentry-cli releases propose-version`
VERSION ?= $(shell sentry-cli releases propose-version)

all: bin/example
.PHONY: all

bin/example: #prereqs src/example.c
	$(CC) -g -o $@ -DSENTRY_RELEASE=\"0.0.1\" -Isentry-native/include src/example.c -Lbin -lsentry_crashpad -Wl,-rpath,"@executable_path"

# prereqs: bin/libsentry_crashpad.dylib bin/crashpad_handler
# .PHONY: prereqs

# bin/libsentry_crashpad.dylib: sentry-makefile
# 	$(MAKE) -C sentry-native/premake sentry_crashpad
# 	cp sentry-native/premake/bin/Release/libsentry_crashpad.dylib bin
# 	cp -R sentry-native/premake/bin/Release/libsentry_crashpad.dylib.dSYM bin

# bin/crashpad_handler: sentry-makefile
# 	$(MAKE) -C sentry-native/premake crashpad_handler
# 	cp sentry-native/premake/bin/Release/crashpad_handler bin
# 	cp -R sentry-native/premake/bin/Release/crashpad_handler.dSYM bin

# not needed for bundled sentry-native download
# sentry-makefile: sentry-native/premake/Makefile
# .PHONY: sentry-makefile

# sentry-native/premake/Makefile:
# 	$(MAKE) -C sentry-native fetch configure

 setup_release: create_release associate_commits upload_debug_files
 .PHONY: setup_release

create_release:
	sentry-cli releases -o $(SENTRY_ORG) new -p $(SENTRY_PROJECT) 0.0.1
.PHONY: create_release

# TODO what to do here?
associate_commits:
	sentry-cli releases -o $(SENTRY_ORG) -p $(SENTRY_PROJECT) set-commits 0.0.1 --auto
.PHONY: associate_commits

upload_debug_files:
	sentry-cli upload-dif --org testorg-az --project $(SENTRY_PROJECT) --wait --include-sources bin/
.PHONY: upload_debug_files

run: clean_db run_app
.PHONY: run

clean_db:
	rm -rf ./sentry-db/*
.PHONY: clean_db

run_app:
	SENTRY_DSN=https://99272e8cd20d41c983790bbddbd28424@sentry.io/1813845 bin/example
.PHONY: run_app

