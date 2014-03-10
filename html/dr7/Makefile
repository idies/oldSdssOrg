DEFAULT:
	@ echo 'Possible Make targets:'
	@ echo ''
	@ echo 'make devel	cvs update, tag cvs, export to das.sdss.org/~sdssdp/dr7web'
	@ echo '		This needs to be run on a machine that can see ~sdssdp on'
	@ echo '		the FNAL EAG Linux cluster.'
	@ echo '		Always do this first!'
	@ echo '		Unfortunately, this takes a while as it needs to export'
	@ echo '		some other data products in addition to the web sites.'
	@ echo '		Bundle your changes before updating the devel site...'
	@ echo ''
	@ echo 'make install	rsync das.sdss.org/~sdssdp/dr7web to www.sdss.org/dr7'
	@ echo '		You need permissions for AFS volume release on the FNAL UNIX'
	@ echo '		cluster to do this successfully.'
	@ echo 'Public or private? Change webPublish.sh call in install: target in this Makefile'
	@ echo '	 	to pick between pre-release private and public install!'

devel:
	cvs update -d
	cd bin; ./develPublish.sh

install:
# For collab-only password-protected pre-release publishing:
#	cd bin; ./webPublish.sh -publish private
# For public publishing:
	cd bin; ./webPublish.sh -publish public
