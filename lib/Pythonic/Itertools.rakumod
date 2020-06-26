unit module Pythonic::Itertools;

sub accumulate($iter, &func = &infix:<+>) is export {
    $iter.produce(&func)
}

sub chain(**@iters) is export {
    @iters.map(-> Iterable $iter { |$iter });
}

sub combinations_with_replacement(@l, $k) is export {
    ([X] ^@l xx $k).unique(:as(~*.sort)).map({ @l[|$_] })
}

sub compress($iter, $selectors) is export {
    ([Z] $iter, $selectors).map({ .[0] if .[1] })
}

sub count(Real $start = 0, Real $step = 1) is export {
    my $inc = $start - $step;
    gather loop {
        take $inc += $step
    }
}

sub cycle(+$iter) is export {
    chain(|$iter xx Inf)
}

sub dropwhile(&pred, $iter) is export {
    $iter.toggle(:off, -> $x { not pred($x) }); 
}

multi sub groupby($data, :&key = {$_}, :&with = &[===], :$kv) is export {
    my $iter = $data.iterator;
    my $next = $iter.pull-one;
    gather for squish($data.map(&key), :&with) -> $key {
        my $group = gather {
            take $next;
            loop {
                $next := $iter.pull-one;
                last if $next =:= IterationEnd or !with($key, key($next));
                take $next;
            }   
        };  
        take $key, $group;
    }   
}

multi sub groupby(@data, &key, |c) is export {
    samewith(@data, :&key, |c)
}

multi sub groupby(@data, :$p!, *%c) is export {
    samewith(@data, |%c).map(-> ($k, $g) { $k => $g })
}

multi sub groupby(@data, :$k!, *%c) is export {
    samewith(@data, |%c).map({ .[0] })
}

multi sub groupby(@data, :$v!, *%c) is export {
    samewith(@data, |%c).map({ .[1] })
}


multi sub islice($iter, Int $stop) { nextwith($iter, 0, $stop) }

multi sub islice($iter, Int $start, Int $stop = 0, Int $step = 1) is export {
    my $it = $iter.iterator;
    if $start > 0 {
        $it.skip-at-least($start);
    }
    gather for ^($stop || Inf) {
        take $it.pull-one;
        $it.skip-at-least($step - 1);
    }
}

proto sub permutations(@n, Int $k?) is default is export { * }

multi sub permutations(@n) { @n.permutations }

multi sub permutations(@n, $k where * == @n.elems) { @n.permutations }

multi sub permutations(@n, $k) {
    my $fac = [×] 2 .. (@n - $k);
    @n.permutations[ 0, * + $fac ... * ].map(*[^$k])
}

multi sub product(@iters, :$repeat) {
    nextwith(@iters, :$repeat)
}

multi sub product(**@iters, :$repeat = 1) is export {
    [X] (@iters xx $repeat).map(-> Iterable $iter { |$iter })
}

multi sub repeat($object, :$times = Inf) is export {
    nextwith($object, $times);
}

multi sub repeat($object, $times = Inf) is export {
    $object xx $times
}

sub starmap(&func, $iter) is export {
    $iter.map({ func(|$_) })
}

sub takewhile(&pred, $iter) is export {
    $iter.toggle(-> $x { pred($x) })
}

sub tee($iter, $n = 2) is export {
    gather for ^$n {
        .take for $iter xx 1
    }
}

sub zip_longest(**@iters, :$fillvalue) is export {
    my $elems = try { @iters».elems.max } // Inf;
    zip(@iters.map(-> $iter { chain($iter, $fillvalue xx *) })).head($elems)
}

