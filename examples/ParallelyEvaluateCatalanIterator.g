#! @System ParallelyEvaluateCatalanIterator

#! This example enumerates all full binary trees with 9 leaves. The number is the sixth Catalan number.

LoadPackage( "ParallelizedIterators" );

#! @Example
ReadPackage( "ParallelizedIterators", "examples/CatalanIterator.g" );
#! true
state := rec( );
#! rec(  )
threads := 2;
#! 2
n := 9;
#! 9
riter := IteratorCatalanTree( [[ 1 .. n ]], [[ 1 ]] );
#! <iterator>
ch := CreateChannel( 10000 );;
scheduler := ParallelyEvaluateRecursiveIterator( state, threads, riter, ch );
#! rec( shutdown := function(  ) ... end )
i := 0;
#! 0
while true do l:=ReceiveChannel( ch ); if l=fail then break; fi; i:=i+1; od;
i;
#! 1430
#! @EndExample
