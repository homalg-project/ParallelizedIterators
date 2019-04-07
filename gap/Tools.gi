#
# ParallelizedIterators: Tools
#
# Implementations
#

##
InstallGlobalFunction( IteratorByUncertainFunction,
  function( r, value_done )
    local iter;
    
    iter :=
      rec(
          data := r,
          
          value_done := value_done,
          
          pre_computed := [ ],
          
          NextIterator := function( i )
                            local v;
                            if Length( i!.pre_computed ) > 0 then
                                return Remove( i!.pre_computed );
                            fi;
                            v := i!.data.NextIterator( i!.data );
                            if v = i!.value_done then
                                Error( i, " is exhausted\n" );
                            fi;
                            return v;
                          end,
          
          IsDoneIterator := function( i )
                              local v;
                              if Length( i!.pre_computed ) > 0 then
                                  return false;
                              fi;
                              v := i!.data.NextIterator( i!.data );
                              if v = i!.value_done then
                                  return true;
                              fi;
                              i!.pre_computed[1] := v;
                              return false;
                            end,
          
          ShallowCopy := function( i )
                           return
                           rec(
                               data := StructuralCopy( i!.data ),
                               value_done := StructuralCopy( value_done ),
                               pre_computed := StructuralCopy( value_done ),
                               iter := ShallowCopy( i!.iter ),
                               NextIterator := i!.NextIterator,
                               IsDoneIterator := i!.IsDoneIterator,
                               ShallowCopy := i!.ShallowCopy
                               );
                         end
          
    );
    
    return IteratorByFunctions( iter );
    
end );

##
InstallGlobalFunction( TwoLevelIterator,
function(list)
  return Iterator(List(list, Iterator));
end );

##
InstallGlobalFunction( ThreeLevelIterator,
function(list)
  return Iterator(List(list, TwoLevelIterator));
end );
