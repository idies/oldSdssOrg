# Text::DB.pm
#
# Copyright (c) 1999-2001 Craig Wiegert <wigie@alum.mit.edu>.
# All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Text::DB;
require 5.002;

$VERSION='0.6';

use Fcntl qw(:flock);

# Load Data::Dumper only if it's available
eval('use Data::Dumper;');
$use_dumper = ($@ eq '');


# HISTORY:
# 0.1 - I/O routines and quoting/unquoting
#       select/update/delete/insert methods
# 0.2 - Added an (optional) DB cache - evaling a Perl expression is
#       2x faster than parsing the text DB.  Also constructor can 
#       optionally read in the DB.
# 0.3 - Added capability for single-line fields.  Fixed bug when key
#       is followed by whitespace
# 0.4 - Changed format of DB to key: val - old two-line format no
#       longer works.  Use version 0.3 to convert (just read/write),
#       or use separate convertDB.pl script.
# 0.5 - Documentation update
# 0.6 - Comments can appear in DB

# TODO:
# Writes to other files?
# Do we really need locks?
# Remember order of keys upon read-in, use same order for write
#   (and put order into cache)

# BRIEF DOCUMENTATION:
#
# Records are separated by blank lines.  Records are of the form
# key1: val1
# key2: val2
#
# The values can be multi-line if the line breaks are escaped by
# backslashes.


# Constructor
# Examples: $db  = new Text::DB;
#           $db  = Text::DB->new('dbfile');
#           $db2 = $db1->new('dbfile2');
sub new
{
    my $type = shift;
    my $class = ref($type) || $type;
    my $self = {};

    $self->{'data'}      = [];
    $self->{'fn'}        = '';
    $self->{'use_cache'} = $use_dumper;
    return undef if (@_ and not Text::DB::read($self, @_));
    bless($self, $class);
}


# Change cache usage - 1 for yes, 0 for no
# Example: $db->use_cache(0);
sub use_cache
{
    my $self  = shift;

    $self->{'use_cache'} = (@_) ? shift : 1;
    return $self;
}


# Read in text database, return number of records read
sub read
{
    local $self = shift;
    my $file = shift;
    my ($cache, $key, $ref);
    my ($cache_mtime, $file_mtime);
    local *FH;
    local $/ = "\n";

    # Check for file
    return undef unless (-r $file);
    $file_mtime = (stat(_))[9];
    $self->{'fn'} = $file;
    $self->{'data'} = [];

    # Use cache if available and new enough
    $cache = "$file.cache";
    if ($self->{'use_cache'} and open(FH, "<$cache"))
    {
	if (flock(FH, LOCK_SH | LOCK_NB) and 
	    $cache_mtime = (stat(FH))[9] and $cache_mtime >= $file_mtime)
	{
	    do $cache;
	    close(FH);
	    return scalar(@{$self->{'data'}});
	}
	close(FH);
    }

    # Read DB file
    if (! open(FH, "<$file") or ! flock(FH, LOCK_SH | LOCK_NB))
    {
	close(FH);
	return undef;
    }
    
  REC:
    while (<FH>)
    {
	next REC if (m/^(\s*|#.*)$/);
	$ref = {};
	push(@{$self->{'data'}}, $ref);
	do
	{
	    if (m/^\s*(\S+):\s*/)
	    {
		$key = $1;
		$ref->{$key} = unquote_string($');
		until (chomp($ref->{$key}))
		{
		    last REC unless defined($_ = <FH>);
		    $ref->{$key} .= unquote_string($_);
		}
		$ref->{$key} = undef if ($ref->{$key} eq "\x00");
	    }
	    else
	    {
		chomp;
		warn "Text::DB: Invalid key-value pair: '$_'\n";
	    }
	    last REC unless defined($_ = <FH>);
	}
	until (m/^\s*$/);
    }
    
    close(FH);
    return scalar(@{$self->{'data'}});
}


# Write out database, possibly modified
sub write
{
    my $self = shift;
    my ($file, $key, $val);
    local *FH;

    $file = "$self->{'fn'}$$";
    if (! open(FH, ">$file") or ! flock(FH, LOCK_EX | LOCK_NB))
    {
	close(FH);
	return undef;
    }
    foreach $rec (@{$self->{'data'}})
    {
	while (($key, $val) = each %$rec)
	{
	    print FH $key, ": ", quote_string($val), "\n";
	}
	print FH "\n";
    }
    close(FH);
    if (! rename($file, $self->{'fn'}))
    {
	unlink($file);
	return undef;
    }

    # Write out cache file 
    if ($self->{'use_cache'} and $use_dumper)
    {
	$file = "$self->{'fn'}.cache$$";
	return 1 unless (open(FH, ">$file"));
	if (! flock(FH, LOCK_EX | LOCK_NB))
	{
	    close(FH);
	    return 1;
	}
	$Data::Dumper::Indent = 1;
	$Data::Dumper::Purity = 1;
	eval('print FH Data::Dumper->Dumpxs([$self->{\'data\'}], 
              [qw($self->{\'data\'})]);');
	if ($@)
	{
	    print FH Data::Dumper->Dump([$self->{'data'}], 
					[qw($self->{'data'})]);
	}
	close(FH);
	unlink($file) unless rename($file, "$self->{'fn'}.cache");
    }
    return 1;
}


# Return an array of records matching the given Perl expression, or the
# entire database if no condition is given
# Example: $db->select('$_{age} < 30')
sub select
{
    my $self = shift;
    my $cond = (@_) ? shift : 1;
    my @result = ();

    foreach $rec (@{$self->{'data'}})
    {
	local %_ = %$rec;
	push(@result, \%_) if (eval $cond);
    }
    return @result;
}


# Update the records matching a given condition by executing the given
# consequent, and return an array of the changed records
# Example: $db->update('$_{year} == 2000', '$_{panic} = "yes"');
sub update
{
    my $self = shift;
    my $cond = (@_) ? shift : 1;
    my $consequent = (@_) ? shift : 1;
    my @result = ();

    foreach $rec (@{$self->{'data'}})
    {
	local %_ = %$rec;
	if (eval $cond)
	{
	    eval $consequent;
	    $rec = \%_;
	    push(@result, \%_);
	}
    }
    return @result;
}


# Delete the database records matching the condition, and return
# an array of the deleted records to the caller
# Example: $db->delete('$_{name} eq "Bill Gates"');
sub delete
{
    my $self = shift;
    my $cond = (@_) ? shift : 1;
    my @deleted = ();
    my @left = ();

    foreach $rec (@{$self->{'data'}})
    {
	local %_ = %$rec;
	if (eval $cond)
	{
	    push(@deleted, \%_);
	}
	else
	{
	    push(@left, $rec);
	}
    }
    $self->{'data'} = \@left;
    return @deleted;
}


# Insert record into database, return new number of records
sub insert
{
    my $self = shift;
    my %rec = @_;

    push(@{$self->{'data'}}, \%rec);
}


#
# Private methods
#

# Backslash-quote an ordinary ASCII string
# Understands null values, newlines, backslashes, continuation lines
sub quote_string
{
    my $str = shift;

    return '\\0' unless defined($str);
    $str =~ s/\x00/\\0/gs;
    $str =~ s/\\/\\\\/gs;
    $str =~ s/\n/\\n/gs;
    # Attempt to break up long lines semi-logically
    if (length($str) > 70)
    {
#	$str =~ s/(.{70}[^\\])(.)/$1\\\n$2/mg;
	$str =~ s/(.{0,70}[^\\]\s)(.)/$1\\\n$2/mg;
	$str = "\\\n" . $str;
    }
    return $str;
}

# Unquote a backslash-quoted string
sub unquote_string
{
    my $str = shift;
    my @fields;
    my $i = 0;

    @fields = split(/\\(.|\n)/, $str);
    foreach (@fields)
    {
	next if ($i ^= 1);
	tr|0n\n|\x00\n|d;
    }
    $str = join('', @fields);
    return $str;
}

1;
