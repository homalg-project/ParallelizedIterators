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
#!  Return a recursive iterator for the list of lists <A>L</A>.
#! @Returns an iterator
#! @Arguments L
DeclareGlobalFunction( "TwoLevelIterator" );

#! @Description
#!  Return a recursive iterator for the list of lists of lists <A>L</A>.
#! @Returns an iterator
#! @Arguments L
DeclareGlobalFunction( "ThreeLevelIterator" );
