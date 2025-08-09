```perl
#!/usr/bin/perl
use strict;
use warnings;

# ------------------------------------------------------------------
#   1. $  – Scalars
# ------------------------------------------------------------------
my $scalar = "Hello, Scalars!";

# ------------------------------------------------------------------
#   2. @  – Arrays
# ------------------------------------------------------------------
my @fruits = ("apple", "banana", "cherry");

# ------------------------------------------------------------------
#   3. %  – Hashes
# ------------------------------------------------------------------
my %colors = (
    apple   => "red",
    banana  => "yellow",
    cherry  => "red",
);

# ------------------------------------------------------------------
#   4. &  – Subroutine
# ------------------------------------------------------------------
sub greet {
    my ($name) = @_;          # @_ holds the arguments
    print "Greetings, $name!\n";
}

# ------------------------------------------------------------------
#   5. *  – Typeglobs
# ------------------------------------------------------------------
# A typeglob can refer to a scalar, array, hash, filehandle, etc.
my $outfile = \*STDOUT;       # $outfile is a reference to STDOUT
print $outfile "Writing directly via a typeglob.\n";

# ------------------------------------------------------------------
#   Demo: iterate through @fruits using $_ (default variable)
# ------------------------------------------------------------------
foreach my $fruit (@fruits) {
    $_ = $fruit;                 # $_ is automatically set
    my $color = $colors{$_};      # look up color in %colors
    print "$_ is $color.\n";
}

# ------------------------------------------------------------------
#   Call subroutine in two ways
# ------------------------------------------------------------------
greet("Perl Enthusiast");       # normal call
&greet("Anonymous");         # explicit & form

# ------------------------------------------------------------------
#   Show @_ inside another subroutine
# ------------------------------------------------------------------
sub sum {
    my $total = 0;
    foreach (@_) {               # @_ is the argument list
        $total += $_;
    }
    return $total;
}
print "Sum of 1, 2, 3: ", sum(1, 2, 3), "\n";

# ------------------------------------------------------------------
#   Special variables that start with $
# ------------------------------------------------------------------
$! = 0;           # last OS error (0 = no error)
print "Last error code is $!\n";

$@ = '';           # last eval error (empty = no error)
print "Eval error: $@\n";

# $^X – the Perl interpreter executable
print "Perl executable is $^X\n";

# $/ – record separator (defaults to newline)
print "Record separator is [$/] \n";

# $#ARGV – index of the last element of @ARGV
print "Number of script arguments: $#ARGV\n";

# $- – command‑line options passed to the interpreter
print "Command‑line options: $-\n";

# ------------------------------------------------------------------
#   Show $0 (script name) and $_ (last used value)
# ------------------------------------------------------------------
print "Script name is $0\n";
$_ = "Now I am $_";    # demonstrate changing $_
print "Special variable now is '$_'\n";

# ------------------------------------------------------------------
#   End of script
# ------------------------------------------------------------------
print "Finished demo!\n";
```

### What this script does

| Sigil | Purpose in script |
|-------|-------------------|
| `$` | Scalars (`$scalar`, `$!`, `$@`, `$^X`, `$0`, etc.) |
| `@` | Array (`@fruits`) |
| `%` | Hash (`%colors`) |
| `&` | Subroutine call (`&greet`) |
| `*` | Typeglob (`$outfile` pointing to `STDOUT`) |

Run the script and you’ll see each sigil being used and the corresponding output printed. This gives a clear, executable example of all the major Perl sigils in action.
