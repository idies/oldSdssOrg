INSTALL_DIR = $(DM_DIR)

default:
	@echo Please invoke this makefile using sdssmake. >&2
	@exit 1

all: 

clean :
	@ echo in .
	rm -f *~ core *.bak *.orig *.old .\#* \#*\#

install:
	@if [ "$(INSTALL_DIR)" = "" ]; then \
		echo You have not specified a destination directory >&2; \
		exit 1; \
	fi
	@ rm -fr $(INSTALL_DIR)/limitFiles
	@ mkdir -m 775 $(INSTALL_DIR)/limitFiles
	@cp -p *.* Makefile $(INSTALL_DIR)/limitFiles
	@chmod g+w $(INSTALL_DIR)/limitFiles/*
