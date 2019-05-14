#
# ParallelizedIterators: Serially evaluate recursive iterators
#
# Declarations
#

#! @Chapter Serially evaluate recursive iterators

#! @Section Serially evaluate recursive iterators

#! @Description
#!  Serially evaluate the recursive iterator <A>iter</A>.
#!  The produced leaves are then returned in a usual iterator.
#! @Returns an iterator of leaves.
#! @Arguments iter
DeclareGlobalFunction( "SeriallyEvaluateRecursiveIterator" );
#! @InsertChunk SeriallyEvaluateCatalanIterator
