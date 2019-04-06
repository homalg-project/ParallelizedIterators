GetDeepListEntry := function( L, p ) 
    local i; 

    for i in p do 
    
        L := L[i]; 
	
    od; 
    
    return L; 
end;

SetDeepListEntry := function( L, p, o ) 
    local i, l; 
    
    l := L; 

    for i in p{[1 .. Length( p ) - 1]} do 

        l := l[i]; 
	
    od; 

    l[p[Length( p )]] := o; 

end;

SplitList := function( list, pos )
    
    list := [list{[1 .. pos]}, list{[pos + 1 .. Length( list )]}];
    
    return list;
    
end;

PossibleSplittings := function( list )
    local result, splitPos;
    
    result := [];
    
    for splitPos in [1 .. Length(list) - 1] do
    
        Add(result, SplitList(list, splitPos));
	
    od;
    
    return result;
    
end;

IteratorCatalanTree := function( treeList, posList )
	local PossibleSplittingsList, pos, iter, r;
	
        treeList := MakeReadOnlyObj( treeList );
        posList := MakeReadOnlyObj( posList );
        
	if Length( treeList ) = 1 and Length( treeList[1] ) = 1 then
	
	    return Iterator( treeList );
	    
	fi;
	
	PossibleSplittingsList := [];
	
	for pos in posList do
	
	    Add( PossibleSplittingsList, PossibleSplittings( GetDeepListEntry( treeList, pos )));
	
	od;
	
	iter := IteratorOfCartesianProduct( PossibleSplittingsList );
	
	r := rec(

	    iter := iter,
	    
		NextIterator := function( i )
			local nextSplitting, newTreeList, newPosList, j;
			
			if IsDoneIterator( i!.iter ) then
			    
			    return fail;
			    
			fi;
			
			nextSplitting := NextIterator( i!.iter );
			
			newTreeList := StructuralCopy( treeList );
			
			newPosList := [];
			
			for j in [1 .. Length( posList )] do
	
			    SetDeepListEntry( newTreeList, posList[j], nextSplitting[j] );
			    
			    if Length( nextSplitting[j][1] ) > 1 then
				
                    Add( newPosList, Concatenation( posList[j], [ 1 ] ));
				
			    fi;
			    
			    if Length( nextSplitting[j][2] ) > 1 then
				
                    Add( newPosList, Concatenation(posList[j], [ 2 ] ));
				
			    fi;
			
			od;
			
			if Length( newPosList ) = 0 then
			
			    return newTreeList;
			    
			fi;
			
			return IteratorCatalanTree( newTreeList, newPosList );
			
		end,
		
		IsDoneIterator := function( i )
			
		    if IsBound( i!.iter ) then
		    
			return IsDoneIterator( i!.iter );
			
		    fi;
		    
		    return true;
		
		end,			

		ShallowCopy := function( i )
			return
			rec(
			   iter := ShallowCopy( i!.iter ),
			   NextIterator := i!.NextIterator,
			   IsDoneIterator := i!.IsDoneIterator,
			   ShallowCopy := i!.ShallowCopy
			   );
		end	   
	);
	
	return IteratorByFunctions( r );
end;