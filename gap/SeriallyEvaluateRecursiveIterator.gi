#
# ParallelizedIterators: Serially evaluate recursive iterators
#
# Implementations
#

##
InstallGlobalFunction( SeriallyEvaluateRecursiveIterator,
  function(iter)
    local stack, previousPath, firstIter, firstInfo, r;

    stack := CreateAugmentedLiFoOfIterators();
    firstIter := iter;

    #This LiFo does not need additional informations.
    firstInfo := [];
    Push(stack, [firstIter, firstInfo]);

    r := rec(
        NextIterator := function( i )
          local next;
          while Length(stack) > 0 do
            next := Pop(stack);
            #Display(next);
            if next = fail then
                #top iterator was empty
                continue;
            elif IsIterator(next) then
                #next is nex iterator to put on stack.
                Push(stack, [next, []]);
            else
                #leaf found.
                return next;
            fi;
          od;
          return fail;
        end,

        IsDoneIterator := function( i )
          if Length(stack) >0 then
              return false;
          fi;
          return true;
        end,

        ShallowCopy := function( i )
          return
          rec(
            NextIterator := i!.NextIterator,
            IsDoneIterator := i!.IsDoneIterator,
            ShallowCopy := i!.ShallowCopy
          );
        end
    );
    return IteratorByFunctions( r );
end );
