#!/bin/bash
verstring=v7_$(date +%Y%m%d_%H%M)
echo Tagging drweb with $verstring
# Check that the setup script exists; if not, assume necessary variables have been set by user
if [ -e /fnal/ups/etc/setups.sh ] ; then
    . /fnal/ups/etc/setups.sh
    setup sdsscvs
fi
rtagval=$(cvs rtag $verstring drweb)
./webPublish.sh -export $verstring
