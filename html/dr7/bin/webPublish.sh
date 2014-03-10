#! /bin/bash

# Publish the dr1web product on to the web server
# This is a 2-step process:
    # 1 export the stuff into ~sdssdp/WWW/drXweb
    # 2 review it, then copy it to the public location under ~sdssdp/WWW/
#
# By giving "-export tag", the script does 1 for the given CVS version tag.
# By giving "-publish" as argument, it does 2.

# todo: log file, error handling
# eg. should check that tag to be exported exists before removing old stuff

# names of modules to export:
#   product: the web site product
#   exp_loc: parent directory of the staging ("devel") area
#   develdir: directory which will contain the "devel" version of the product
#   dmtag:   tag for product "dm" pertaining to this data release
#   dmdir:   root name of subdirectory of exp_loc that will contain dm (includes product and version tag)
#   wdcat_tag: tag for product "wdcat" pertaining to this data release
#   wddir:   root name of subdirectory of exp_loc that will contain wdcat (includes product and version tag)
# dmdir and wddir are then linked into the web site tree, to avoid having to re-export them over and over
# This means that the exporting of dm and wdcat has to be done by hand
# if you want to keep the same tag after making changes to either
# product.
product=drweb
develdir=dr7develweb
exp_loc="/home/s1/sdssdp/WWW"
pubdir=/afs/.fnal.gov/files/expwww/sdss/html/dr7
pubhost=flxi02
# public_loc: web server location
public_loc="${pubhost}:${pubdir}"
# cvs tags and export directories for data model (dm) and white-dwarf catalog (wdcat)
dmtag=v4_2
dmdir="${exp_loc}/dm_${dmtag}"
wdcat_tag=v1_3
wddir="${exp_loc}/wdcat_${wdcat_tag}"
# Choose default access privileges for -publish option (pages on sdss.org): private or public
default_access=private

print_usage () {
    echo 'Usage:    webPublish.sh [-export tag] [-publish [private]] '
    echo '          -publish and -export are mutually exclusive'
    echo "Synopsis: -export: export tagged version from CVS to $exp_loc/${develdir}"
    echo '                Before calling this, you need to do cvs rtag:'
    echo "                    cvs rtag [-r branch_tag] vXXX ${product}"
    echo "                where vXXX is the version tag."
    echo "          -publish: "
    echo "                publish from $exp_loc/${develdir} to $public_loc"
    echo "                If private is also given, limit access to collaboration"
    echo
    echo " To publish on www.sdss.org/DR7, call -export first, then -publish"
    exit 1
}

export_tagged () {
    current=$PWD

    TAG="$1"
    # Check export location exists and I can write to it
    if [ ! -d "$exp_loc" ] ; then
	echo "Error: $exp_loc is not a directory or doesn't exist"
	exit 1
    elif [ ! -w "$exp_loc" ] ; then
	echo "You can't write to $exp_loc"
	exit 1
    fi
    if [ ! -w "${exp_loc}/${develdir}" ] ; then
	echo "You can't write to ${exp_loc}/${develdir}"
	exit 1
    fi
    cd $exp_loc
    # Clean up old stuff
    echo "Doing  rm -rf $PWD/${develdir}"
    rm -rf ${develdir}/
    # Export new version
    echo "Exporting ${product} to $PWD..."
    cvs export -r $TAG -d $develdir ${product}
    cd ${develdir}
    # Make cvs version tag in exported file look prettier
    sed -e '/parse_this/ s!\(\$\|Name\|:\)!!g' < index.html > temp_main.html
    mv temp_main.html index.html
    # Export data model and White Dwarf catalog into exported web sites

    # Re-exporting ALL of this every time we just change the web page is a bit silly.
    # We should just copy the dm and the wdcat to a directory that contains the 
    # tag name under ~sdssdp/WWW/ and then softlink that directory into the drweb tree.
    export_dm $dmtag $dmdir
    export_wdcat $wdcat_tag $wddir
    # Remove stuff that's only for bookkeeping, not for the public web page
    clean_obsolete "Makefile bin/ templates/ algorithms/dr2changes.html sitemap.html"
    make_html_user_executable .
    set_permissions

    echo "Done!"    
    cd $current
    exit 0
}

set_permissions() {
    # Set permissions so other people can overwrite the exported pages
    echo "Giving ${exp_loc}/${develdir} to sdssdp.sdss"
    chmod -R ug+w ${exp_loc}/${develdir}
    chown -R sdssdp.sdss ${exp_loc}/${develdir} 2>/dev/null
} 

export_dm () {
    # Export data model from cvs
    tag=$1
    expdir=$2
    if [ ! -e $expdir ] ; then
	mkdir $expdir
	cur=$PWD
	cd $expdir
	echo "Exporting data model to $expdir"
	dm_dirlist="limitFiles flatFiles"
	for directory in $dm_dirlist ; do
	    cvs export -r $tag -d $directory dm/$directory 
	done
	cd $cur
    fi
    ln -s $expdir ${exp_loc}/${develdir}/dm
}

export_wdcat () {
    tag=$1
    expdir=$2
    cur=$PWD
    if [ ! -e $expdir ] ; then
	mkdir $expdir
	cd $expdir/../
	echo "Exporting wdcat to $expdir..."
	cvs export -r $tag -d ${expdir##*/} wdcat
    else
	cd products/value_added
	ln -s $expdir wdcat
    fi
    cd $cur
}

clean_obsolete () {
    clean_dir_list="$1"
        echo "Cleaning $clean_dir_list"
    for directory in $clean_dir_list ; do 
	rm -rf $directory
	echo "removed $directory"
    done
}

make_html_user_executable () {
    echo "Making html files (except dm) u+x so includes work..."
    dir="$1"
    for i in `find $dir -path "$dir/dm" -prune -o -name \*.html -print`
    do
      chmod u+x $i
    done
}

publish () {
    # copy $exp_loc to $public_loc
    exp_dir=${exp_loc}/${develdir}
    #rsync -r -L -W -t -v --delete ${exp_dir}/ ${public_loc}
    # the previous line does not work as I expected and I can't see why not.
    # I think the -L is dodgy - it looks like it can't cope with the links now.
    # June 2003: it seems to work now, so I am using rsync again instead of scp.
    # For some reason, though, it seems to insist on copying everything if someone else exported before me.
    if [ -n $1 ]; then
	if [ "$1" = "private" ]; then 
	    # Add check here whether we're exporting to devel.sdss.org
	    # which (apparently) is "private anyway"?
	    echo "Executing htaccess <-> .htaccess hack to add access control to public site"
	    mv ${exp_dir}/htaccess ${exp_dir}/.htaccess
       # New: remove htaccess for public releases right away, instead of only after rsync
	else
	    rm ${exp_dir}/htaccess
	fi
    fi
    echo "rsync -pvrtLW --copy-unsafe-links --delete ${exp_dir}/ ${public_loc}"
    rsync -pvrtLW --copy-unsafe-links --delete ${exp_dir}/ ${public_loc}
    # With the rm htacess above, I think the following if statement is
    # obsolete (and especially if we check above whether we're
    # exporting to devel.sdss.org)
    if [ -n $1 ]; then
	if [ "$1" = "private" ]; then
	    # Devel location is private anyway 
	    mv ${exp_dir}/.htaccess ${exp_dir}/htaccess
	else
	    ssh ${pubhost} "rm -f $pubdir/htaccess"
	fi
    fi
    # new for AFS; only certain people can do this
    ssh ${pubhost} "/usr/local/bin/upd_volrelease $pubdir"
    exit 0
}
    
if [ -z "$1" ]; then
    print_usage
fi

while [ -n "$1" ]; do
    case $1 in
	-export ) shift
	    if [ -z "$1" ]; then
		print_usage
	    fi
	    export_tagged $1 ;;
	-publish ) shift
	    if [ -n "$1" ]; then
		case $1 in
		    private ) publish private ;;
		    public ) publish public ;;
		    \? ) print_usage ;;
		esac
	    else
		if [ "$default_access" = "private" ]; then
		    publish private
		else
		    publish public
		fi
	    fi ;;
	\? ) print_usage ;;
    esac
    shift
done
