#
# Tools
#
# Declarations
#

#! @Chapter Tools

#! @Section Tools

#!
DeclareInfoClass( "InfoRecursiveIterator" );

#! @Description
#!  <C>IteratorByUncertainFunction</C> returns a (mutable) iterator
#!  <C>iter</C> for which <C>NextIterator</C>, <C>IsDoneIterator</C>, and <C>ShallowCopy</C>
#!  are computed via prescribed functions.
#!  The input <A>r</A> is a record having at least the component <C>NextIterator</C>.
#!  The latter is a function taking the single argument <C>iter</C> and returns the next element of <C>iter</C>.
#!  Further (data) components may be contained in record which can be used by these function.
#!  <C>IteratorByUncertainFunction</C> does not make a shallow copy of record, this record is changed in place.
#! @Returns an iterator
#! @Arguments r, value_done
DeclareGlobalFunction( "IteratorByUncertainFunction" );

#! @Description
#!  Return a recursive iterator for the list of lists <A>L</A>.
#! @Returns an iterator
#! @Arguments L
DeclareGlobalFunction( "TwoLevelIterator" );

#! @Description
#!  Return a recursive iterator for the list of lists of lists <A>L</A>.
#! @Returns an iterator
#! @Arguments L
DeclareGlobalFunction( "ThreeLevelIterator" );
