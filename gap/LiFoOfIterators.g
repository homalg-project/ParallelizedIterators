DeclareCategory( "IsLiFo",
        IsComponentObjectRep );

DeclareRepresentation( "IsAugmentedLiFoOfIteratorsRep",
        IsLiFo,
        [ "LiFo", "info" ] );

BindGlobal( "TheFamilyOfLiFos",
        NewFamily( "TheFamilyOfLiFos" ) );

BindGlobal( "TheTypeAugmentedLiFoOfIterators",
        NewType( TheFamilyOfLiFos,
                IsAugmentedLiFoOfIteratorsRep ) );

CreateAugmentedLiFoOfIterators := function( )
  local L;
  
  L := rec( LiFo := [ ], info := [ ] );
  
  ## Objectify
  Objectify( TheTypeAugmentedLiFoOfIterators, L );
  
  return L;
  
end;

##
InstallOtherMethod( Length,
        "for LiFos",
        [ IsLiFo ],

  function( L )
    
    return Length( L!.LiFo );
    
end );

DeclareOperation( "Push", [ IsLiFo, IsObject ] );
DeclareOperation( "InfoOfLiFo", [ IsLiFo ] );
DeclareOperation( "Pop", [ IsLiFo ] );

##
InstallMethod( Push,
        "for augmented LiFos of iterators",
        [ IsAugmentedLiFoOfIteratorsRep, IsList ],
        
  function( L, l )
    
    Add( L!.LiFo, l[1] );
    Add( L!.info, l[2] );
    
end );

##
InstallMethod( InfoOfLiFo,
        "for LiFos",
        [ IsAugmentedLiFoOfIteratorsRep ],

  function( L )
    
    return L!.info[Length( L )];
    
end );

##
InstallMethod( Pop,
        "for LiFos",
        [ IsAugmentedLiFoOfIteratorsRep ],

  function( L )
    local lifo, l, iter, res;
    
    lifo := L!.LiFo;
    
    l := Length( lifo );
    
    iter := lifo[l];
    
    if IsDoneIterator( iter ) then
        Remove( lifo, l );
        Remove( L!.info, l );
        return fail;
    fi;
    
    res := NextIterator( iter );
    
    if IsDoneIterator( iter ) then
        Remove( lifo, l );
        Remove( L!.info, l );
    fi;
    
    return res;
    
end );

##
InstallMethod( ViewObj,
        "for augmented LiFos of iterators",
        [ IsAugmentedLiFoOfIteratorsRep ],
        
  function( L )
    
    Print( "<An augmented LiFo of iterators of length ", Length( L ), ">" );
    
end );
