#! @System example
# This example enumerates all full binary trees with 9 leaves. The number is the sixth Catalan number.

LoadPackage( "ParallelizedIterators" );
Read( "CatalanIterator.g" );

#! @Example
state := rec( );
#! rec(  )
numberOfThreads := 2;
#! 2
n := 9;
#! 9
recursiveIterator := IteratorCatalanTree( [[1 .. n]], [[1]] );
#! <iterator>
iterChannel := CreateChannel( 10000 );
#! <channel 0xa586e88: 0/10000 elements, 0 waiting>
scheduler := ParallelyEvaluateRecursiveIterator(state, numberOfThreads, recursiveIterator, iterChannel);
#! rec( shutdown := function(  ) ... end )
i := 0;
#! 0
while true do
    elem := ReceiveChannel( iterChannel );    
    if elem = fail then break; fi;    
    i := i + 1;
od;
i;
#! 1430
