# SPDX-License-Identifier: GPL-2.0-or-later
# ParallelizedIterators: Parallely evaluate recursive iterators
#
# Declarations
#

#! @Chapter Parallely evaluate recursive iterators

#! @Section Info Classes

#!
DeclareInfoClass( "InfoPtree" );

#!
DeclareInfoClass( "InfoRecursiveIterator" );

#! @Section Parallely evaluate recursive iterators

# @Arguments pq, prio, elem
DeclareGlobalFunction( "InsertPriorityQueue" );

# @Arguments pq
DeclareGlobalFunction( "GetPriorityQueue" );

# @Arguments prio, iter
DeclareGlobalFunction( "NextLocallyUniformRecursiveIterator" );

# @Arguments state
DeclareGlobalFunction( "EvaluateLocallyUniformRecursiveIterator" );

# @Arguments prio, iter
DeclareGlobalFunction( "NextRecursiveIterator" );

# @Arguments state
DeclareGlobalFunction( "EvaluateRecursiveIterator" );

# @Arguments  evaluate_function, state 
DeclareGlobalFunction( "LaunchWorkers" );

#! @Description
#!  Parallely evaluate the recursive iterator <A>iter</A> using <A>n</A> workers (threads).
#!  Save the internal state of computations in the given (usually empty) record <A>state</A>,
#!  for the user to be able to trace the internal state of computations.
#!  The produced leaves are then written to the channel <A>ch</A>.
#!  The procedure returns a record containing the component shutdown,
#!  which is a no-argument function the user can call to terminate the parallel evaluation.
#! @Returns a record
#! @Arguments state, n, iter, ch
DeclareGlobalFunction( "ParallelyEvaluateRecursiveIterator" );
#! @InsertChunk ParallelyEvaluateCatalanIterator
