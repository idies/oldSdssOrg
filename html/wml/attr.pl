#!/usr/bin/perl

use Text::ParseWords;

# Take a string and return an array of name,value,name,value,...
# (do this so that attribute order isn't compromised)
sub parse_attr
{
    my ($str) = @_;
    my @words = quotewords(' +', 1, $str);
    my $i;

    for ($i = 0; $i <= $#words; $i += 2)
    {
	next if ($words[$i] =~ s/=$//);
	if ($words[$i] =~ m/\b=/)
	{
	    splice(@words, $i, 1, $`, $');
	    next;
	}
	if ($words[$i+1] eq '=')
	{
	    splice(@words, $i+1, 1);
	    next;
	}
	next if ($words[$i+1] =~ s/^=//);
	
	splice(@words, $i+1, 0, '');
    }
    return @words;
}

# Take a name,value,name,value,... array,
# and remove the name,value pairs matching the given name
sub remove_attr
{
    my ($name, @arr) = @_;
    my $i;

    for ($i = 0; $i <= $#arr; $i += 2)
    {
	splice(@arr, $i, 2) if ($arr[$i] eq $name);
    }
    return @arr;
}    


$a = 'a="b" c= "d"  e  ="f" g=h i=j   q=w';
@b = parse_attr($a);
@c = remove_attr('q', @b);
print join(':', @b), "\n";
print join(':', @c), "\n";
