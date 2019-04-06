# ParallelizedIterators: Parallely evaluate recursive iterators
#
# Declarations
#

#! @Chapter Serial Iterators

#! @Section Serial evaluate recursive iterators

#! @Description
#!  Serially evaluate the recursive iterator <A>iter</A>.
#!  The produced leaves are then returned in a usual iterator.
#! @Returns an iterator of leaves.
#! @Arguments iter
DeclareGlobalFunction( "SeriallyEvaluateRecursiveIterator" );