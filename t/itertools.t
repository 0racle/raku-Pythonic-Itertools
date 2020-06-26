use v6;
use Test;
use lib $?FILE.IO.parent ~ '/../lib';;
use Pythonic::Itertools;

### ACCUMULATE

# Default is addition
is-deeply accumulate([1, 2, 3, 4, 5]), (1, 3, 6, 10, 15),
  'accumulate with default'
;

# Can pass in WhateverCode
is-deeply accumulate([1, 2, 3, 4, 5], * + *²), (1, 5, 14, 30, 55),
  'accumulate with lambda';

# Or can pass in any Callable
is-deeply accumulate([1, 2, 3, 4, 5], &infix:<*>), (1, 2, 6, 24, 120),
  'accumulate with named sub';

# Lazy infinite Seq's are ok too
is-deeply accumulate(1 .. Inf, * × *)[^6], (1, 2, 6, 24, 120, 720),
  'accumulate with infinite range and lambda';

# A few more tests
my @data = 3, 4, 6, 2, 1, 9, 0, 7, 5, 8;
is-deeply accumulate(@data, * × *), (3, 12, 72, 144, 144, 1296, 0, 0, 0, 0),
  'accumulate with Falsey values';
is-deeply accumulate(@data, &max), (3, 4, 6, 6, 6, 9, 9, 9, 9, 9),
  'accumulate with repeated values';



### CHAIN

my @a = < A B C >;
my @b = < D E F >;
my @c = @a, @b;

my $slip     = (|@a, |@b);
my $non-slip = ( @a,  @b);

is-deeply chain(@a, @b), $slip, 'chain(@) does slip';
is-deeply chain(@c), $non-slip, 'chain(@[@, @]) does not slip';
is-deeply chain(|@c), $slip, 'chain(|@[@, @]) does slip';
is-deeply chain([@a], [@b]), $slip, 'chain: one-arg lists get slipped';
is-deeply chain([@a, @b]), $non-slip, 'chain: matrices do not get slipped';
#is-deeply chain([[@a], [@b]]), $non-slip;  # semantically similar to above


### COMBINATIONS WITH REPLACEMENTS

is-deeply combinations_with_replacement(< A B C >, 2),
    (<A A>, <A B>, <A C>, <B B>, <B C>, <C C>), 'C(3, 2)';

is-deeply combinations_with_replacement(< A A A >, 2),
    (<A A>, <A A>, <A A>, <A A>, <A A>, <A A>), 'C(3, 2) with duplicates';

is-deeply combinations_with_replacement(< A B C >, 3),
    (<A A A>, <A A B>, <A A C>, <A B B>, <A B C>,
     <A C C>, <B B B>, <B B C>, <B C C>, <C C C>,), 'C(3, 3)';

is-deeply combinations_with_replacement(< A A A >, 3),
    (<A A A>, <A A A>, <A A A>, <A A A>, <A A A>,
     <A A A>, <A A A>, <A A A>, <A A A>, <A A A>,), 'C(3, 3) with duplicates';


### COMPRESS

is-deeply compress(<A B C D E F>, [1, 0, 1, 0, 1, 1]), <A C E F>,
  'compress(@, @)';

# Initial arg can be infinite lazy Seq
is-deeply compress(['A' .. *], [1, 0, 1, 0, 1, 1, 0, 1]), <A C E F H>,
  'compress([^Inf], @)';



### COUNT

is-deeply count()[^5], (0, 1, 2, 3, 4), 'count()';
is-deeply count(10)[^5], (10, 11, 12, 13, 14), 'count(start)';
is-deeply count(2.5, 0.5)[^3], (2.5, 3.0, 3.5), 'count(start, step)';



### CYCLE

is-deeply cycle(<A B C D>)[^12], <A B C D A B C D A B C D>, 'cycle()';

# Unfazed by infinite Seqs, though it will never truly cycle
is-deeply cycle(1 .. Inf)[^10], (1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
  'cycle(Inf) produces infinite Seq';



### DROPWHILE

is-deeply dropwhile(* < 5, [1, 4, 6, 4, 1]), (6, 4, 1),
  'dropwhile(&, @)';

# Works with infinitelazy lists too
is-deeply dropwhile(* < 3, 0 .. Inf)[^3], (3, 4, 5),
  'dropwhile(&, ^Inf)';



### GROUPBY

# [k for k, g in groupby('AAAABBBCCDAABBB')] --> A B C D A B

my @l = (<A A A A B B B C C D A A B B B>);

is-deeply groupby(@l),
    (
        ('A', (<A A A A>).Seq),
        ('B', (<B B B>  ).Seq),
        ('C', (<C C>    ).Seq),
        ('D', (<D>      ).Seq),
        ('A', (<A A>    ).Seq),
        ('B', (<B B B>  ).Seq)
    ), 'groupby()';


is-deeply groupby(@l).map(-> ($k, $g) { $k }), @l.squish,
    'groupby keys are squished';



### PERMUTATIONS
# Rakudo has a built in `permutations` Routine, however it does not do P(n, k)
# aka, partial permutations of n items taken k at a time.
# aka, variations, aka, k-tuples

is-deeply permutations(<A B C D>, 2),
    (<A B>, <A C>, <A D>, <B A>, <B C>, <B D>,
     <C A>, <C B>, <C D>, <D A>, <D B>, <D C>),
    'P(4, 2)';

is-deeply permutations(<A B C D>, 3),
    (<A B C>, <A B D>, <A C B>, <A C D>, <A D B>, <A D C>,
     <B A C>, <B A D>, <B C A>, <B C D>, <B D A>, <B D C>,
     <C A B>, <C A D>, <C B A>, <C B D>, <C D A>, <C D B>,
     <D A B>, <D A C>, <D B A>, <D B C>, <D C A>, <D C B>),
    'P(4, 3)';



### PRODUCT

# product('ABCD', 'xy') --> Ax Ay Bx By Cx Cy Dx Dy
is-deeply product(<A B C D>, <x y>),
    (<A x>, <A y>, <B x>, <B y>, <C x>, <C y>, <D x>, <D y>),
    'product with uneven lists';

# product(range(2), repeat=3) --> 000 001 010 011 100 101 110 111
is-deeply product(^2, :repeat(3)),
    ((0,0,0),(0,0,1),(0,1,0),(0,1,1),(1,0,0),(1,0,1),(1,1,0),(1,1,1)),
    'product with repeat';



### REPEAT

# repeat(10, 3) --> 10 10 10
is-deeply repeat(10, 3), (10, 10, 10), 'repeat N times';

# Default is repeat infinitely
is-deeply repeat(10)[^3], (10, 10, 10), 'repeat Inf times';



### STARMAP

# starmap(pow, [(2,5), (3,2), (10,3)]) --> 32 9 1000

sub pow($a, $b) { $a ** $b }
my @args = (2,5), (3,2), (10,3);

is-deeply starmap(&pow, @args), @args.map({ pow(|$_) }),
  'starmap(&f, @a) is eqv to @a.map({ f(|$_) })';

is-deeply starmap(&pow, @args), @args.map(|*.map(&pow)),
  'starmap(&f, @a) is eqv to @a.map(|*.map(&f))';



### TAKEWHILE
is-deeply takewhile(* < 5, [1, 4, 6, 4, 1]), (1, 4), 'takewhile with list';

is-deeply takewhile(* < 3, 0 .. Inf), (0, 1, 2), 'takewhile with infinite seq';



# TEE

is-deeply tee(<A B C>), (<A B C>, <A B C>), 'tee';

is-deeply tee((0, 3 ... Inf)[^5], 3),
    ((0, 3, 6, 9, 12), (0, 3, 6, 9, 12), (0, 3, 6, 9, 12)), 'tee with Inf';



# ZIP_LONGEST

is-deeply zip_longest(<A B C D>, <x y>, :fillvalue<->),
    (<A x>, <B y>, <C ->, <D ->), 'zip_longest';



# RECIPES

is-deeply islice(compress(count(1), cycle(0, 1)), 0, 5), (2, 4, 6, 8, 10), 'recipe 1';
is-deeply product(repeat(^2, 2), :repeat(2)), ((^2, ^2), (^2, ^2), (^2, ^2), (^2, ^2)), 'recipe 2';

done-testing;
# vim: ft=perl6
