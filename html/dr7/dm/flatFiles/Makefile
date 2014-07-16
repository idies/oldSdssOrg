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
	@ rm -fr $(INSTALL_DIR)/flatFiles
	@ mkdir -m 775 $(INSTALL_DIR)/flatFiles
	cp -p *.html *.gif *jpg Makefile $(INSTALL_DIR)/flatFiles
	chmod -R g+w $(INSTALL_DIR)/flatFiles
