#! @Chunk SeriallyEvaluateCatalanIterator

#! This example enumerates all full binary trees with 9 leaves. The number is the sixth Catalan number.

LoadPackage( "ParallelizedIterators" );

#! @Example
ReadPackage( "ParallelizedIterators", "examples/CatalanIterator.g" );
#! true
n := 9;
#! 9
riter := IteratorCatalanTree( [[ 1 .. n ]], [[ 1 ]] );
#! <iterator>
liter := SeriallyEvaluateRecursiveIterator( riter );
#! <iterator>
i := 0;
#! 0
while not IsDoneIterator( liter ) do NextIterator( liter ); i:=i+1; od;
i;
#! 1430
#! @EndExample
