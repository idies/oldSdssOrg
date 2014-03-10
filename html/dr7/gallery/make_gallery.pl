#!/usr/bin/perl

use lib "$ENV{HOME}/perl";

use Text::DB;

close STDOUT;

open STDOUT, ">gal_data.html"; 
print "<!--#include virtual=\"/includes/sdss_page_top.html\"-->\n";
&print_gallery('../data');
print "\n<!--#include virtual=\"/includes/sdss_page_bottom.html\"-->\n";
close STDOUT;

open STDOUT, ">gal_photos.html"; 
print "<!--#include virtual=\"/includes/sdss_page_top.html\"-->\n";
&print_gallery('../photos','(telescope|people)');
print "\n<!--#include virtual=\"/includes/sdss_page_bottom.html\"-->\n";
close STDOUT;

open STDOUT, ">gal_spectra.html"; 
print "<!--#include virtual=\"/includes/sdss_page_top.html\"-->\n";
print "\n<h2>Quasars</h2>\n";
&print_gallery('../data/spectra', 'quasar');
print "\n<h2>Galaxies</h2>\n";
&print_gallery('../data/spectra', 'galaxy');
print "\n<h2>Stars</h2>\n";
&print_gallery('../data/spectra', 'star');
print "\n<!--#include virtual=\"/includes/sdss_page_bottom.html\"-->\n";
close STDOUT;

exit;

# Print out a list of images in a directory, in a specified category 
# if one is given 
# Usage: print_images($dir, $category);
sub print_gallery
{
    my $dir = shift;
    my $cat = shift;
    my ($db, $fn, $img, $img2, $res, $fmt);
    my @recs;
    my @imgs;

    # Read in gallery DB, select and sort by ID
    $dir =~ s|/$||;
    $db = new Text::DB;
    $db->read("$dir/image.db");
    if ($cat)
    {
	@recs = $db->select("\$_{'category'} =~ m/$cat/");
    }
    else
    {
	@recs = $db->select;
    }
#    @recs = sort( { $a->{'id'} cmp $b->{'id'} } @recs);

    foreach $rec (@recs)
    {
	print '<p>';
	$fn = "$dir/$rec->{'id'}";
	$img = imagename("$fn.tn");
	$img2 = imagename("$fn.web1");

	next if (!$img);
	if ($img)
	{
	    print '<a href="',$img2,'">' if ($img2);
	    print '<img src="',$img,'" alt="" align="left" hspace="4" vspace="2">';
	    print '</a>' if ($img2);
	}

	print '<strong>';
	print (($rec->{'title'}) ? $rec->{'title'} : $rec->{'id'});
	print "</strong>\n";

	# Print links to all resolutions and postscript files
	@imgs = ();
	push(@imgs, glob("$fn.*dpi.*"));
	push(@imgs, glob("$fn.*ps"));
	if (@imgs)
	{
	    @imgs = sort(imagesort @imgs);
	    print ' [ ';
	    while ($img = shift(@imgs))
	    {
		if ($img =~ m|\.([0-9]+)dpi\.(.+)$|)
		{
		    $res = $1;
		    $fmt = uc($2);
		    print '<a href="',$img,'">',$res,' dpi ',$fmt,'</a>';
		}
		else
		{
		    print '<a href="',$img,'">PS</a>';
		}
		print ' <small>(',filesize($img),')</small>';
		print ', ' if (@imgs);
	    }
	    print " ]<br>\n";
	}

	if ($rec->{'caption'})
	{
	    print '<small>', $rec->{'caption'}, "</small><br>\n";
	}
	if ($rec->{'credit'})
	{
	    print '<em>(Image credit: ', $rec->{'credit'}, ")</em><br>\n";
	}
	
	print "</p><br clear=\"all\">\n";
    }
}


# Return full image filename if it exists, or undef if it doesn't
sub imagename
{
    my $fn = shift;

    return "$fn.jpg" if (-f "$fn.jpg");
    return "$fn.gif" if (-f "$fn.gif");
    return "$fn.png" if (-f "$fn.png");
    return "$fn.tiff" if (-f "$fn.tiff");
    return undef;
}


# Return nicely formatted file size
sub filesize
{
    my $fn = shift;
    my $size = (stat($fn))[7];
    my $frac;

    return "$size bytes" if ($size < 1024);
    $size /= 1024;
    return sprintf("%.1f KB", $size) if ($size < 1024);
    $size /= 1024;
    return sprintf("%.1f MB", $size) if ($size < 1024);
    $size /= 1024;
    return sprintf("%.1f GB", $size);
}


# Image sorting routine - to sort multiple resolutions/extensions of
# the same image
sub imagesort
{
    my ($dpi_a, $dpi_b);
    my ($ext_a, $ext_b);

    ($dpi_a) = ($a =~ m/(\d+)dpi/);
    ($dpi_b) = ($b =~ m/(\d+)dpi/);
    return 1 if ($dpi_a > $dpi_b);
    return -1 if ($dpi_a < $dpi_b);
    ($ext_a) = ($a =~ m/\.\w+$/);
    ($ext_b) = ($b =~ m/\.\w+$/);
    return ($ext_a cmp $ext_b);
}

