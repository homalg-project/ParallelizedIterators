#
# ParallelizedIterators: LiFo Of iterators
#
# Declarations
#

#! @Chapter LiFo of iterators

#! @Section Info Class

#! @Description
#!  The &GAP; category of augmented LiFos of iterators
DeclareCategory( "IsLiFo",
        IsNonAtomicComponentObjectRep );

#! @Section LiFo of iterators

#!  These are helper procedures which can be used to build a recursive iterator.

#! @Arguments L
#! @Returns an augmented LiFo of iterators
DeclareGlobalFunction( "CreateAugmentedLiFoOfIterators" );


#! @Arguments L
#! @Returns a nonnegative integer
DeclareAttribute( "Length", IsLiFo );

#! @Arguments L
#! @Returns nothing
DeclareOperation( "Push", [ IsLiFo, IsObject ] );

#! @Arguments L
#! @Returns a list
DeclareOperation( "InfoOfLiFo", [ IsLiFo ] );

#! @Arguments L
#! @Returns fail, an iterator, or an object (as a leaf)
DeclareOperation( "Pop", [ IsLiFo ] );
