DeclareInfoClass( "InfoPtree" );
SetInfoLevel( InfoPtree, 1 );

InsertPriorityQueue := function(pq, prio, elem)
  if not IsBound( pq[prio] ) then
      pq[prio] := MigrateObj( [ elem ], pq );
  else
      Add( pq[prio], MigrateObj( elem, pq ) );
  fi;
end;

GetPriorityQueue := function(pq)
  local len, result;
  len := Length(pq);
  if len = 0 then
    return [fail, fail];
  fi;
  result := MigrateObj( [ len, Remove( pq[len] ) ], pq );
  if pq[len] = [ ] then
      Unbind(pq[len]);
  fi;
  return result;
end;

NextLocallyUniformRecursiveIterator := function(prio, iter)
  local next, leaves;
  
  if IsDoneIterator(iter) then
    return [];
  fi;
  
  next := NextIterator(iter);
  
  if IsIterator(next) then
    return [ prio+1, next ];
  fi;
  
  leaves := [ next ];
  
  while not IsDoneIterator(iter) do
    Add(leaves, NextIterator(iter));
  od;
  
  return [ leaves ];
end;

EvaluateLocallyUniformRecursiveIterator := function(state)
  local name, sem, ch, prio, iter, next, len, leaf, i;
  
  atomic state do
    state.current_number_of_workers := state.current_number_of_workers + 1;
    state.last_assigned_number := state.last_assigned_number + 1;
    name := Concatenation( "worker ", String( state.last_assigned_number ), " in thread #", String( ThreadID( CurrentThread( ) ) ) );
    sem := state.semaphore;
    ch := state.leaf_channel;
  od;
  
  SetRegionName( "", name );
  Print( "I am ", name, ". Welcome to my local thread.\n" );
  
  while true do
    atomic state do
      state.(name) := MakeImmutable( "Waiting for semaphore" );
    od;
    Print( "Waiting for semaphore ...\n" );
    WaitSemaphore(sem);
    atomic state do
      state.(name) := MakeImmutable( "Waiting for semaphore ... DONE" );
    od;
    Print( "Done.\n" );
    atomic state do
      Print( "currently ", state.number_of_current_jobs, " jobs awaiting free workers\n" );
      if state.canceled then
        iter := fail;
      else
        state.(name) := MakeImmutable( "GetPriorityQueue" );
        Print( "GetPriorityQueue ...\n" );
	iter := GetPriorityQueue(state.pq);
        state.(name) := MakeImmutable( "GetPriorityQueue ... DONE" );
        Print( "Done.\n" );
	prio := iter[1];
	iter := iter[2];
        state.(name) := MakeImmutable( "Adopt ..." );
        Print( "Adopt ...\n" );
	AdoptObj(iter);
        state.(name) := MakeImmutable( "Adopt ... DONE" );
        Print( "Done.\n" );
      fi;
    od;
    if iter = fail then
      atomic state do
        state.(name) := MakeImmutable( "Terminated!" );
      od;
      QUIT_GAP();
    fi;
    atomic state do
      state.(name) := MakeImmutable( Concatenation( "Computing at priority level ", String( prio ), " ..." ) );
    od;
    Print( "Computing ...\n" );
    next := NextLocallyUniformRecursiveIterator(prio, iter);
    Print( "Done.\n" );
    atomic state do
      state.(name) := MakeImmutable( Concatenation( "Computing at priority level ", String( prio ), " ... DONE" ) );
    od;
    len := Length(next);
    atomic state do
      if len = 0 then # next = [ ], the iterateor is done without producing leaves
        
        state.number_of_current_jobs := state.number_of_current_jobs - 1;
        
      elif len = 1 then # next = [ [ leaves ] ], the iterator is done producing leaves
        
        ## write all produced leaves to the channel
        state.(name) := MakeImmutable( Concatenation( "Sending ", String( Length(next[1]) ), " leaves to channel ..." ) );
        Print( "Sending ", Length(next[1]), " leaves to channel ...\n" );
        for leaf in next[1] do
          SendChannel(ch, leaf);
        od;
        state.(name) := MakeImmutable( Concatenation( "Sending ", String( Length(next[1]) ), " leaves to channel ... DONE" ) );
        Print( "Done.\n" );
        
        state.number_of_leaves := state.number_of_leaves + Length(next[1]);
        state.number_of_current_jobs := state.number_of_current_jobs - 1;
        
      elif len = 2 then # next = [ prio, iter ] -> next task step
        
        ## insert next iterator into priority queue
        state.(name) := MakeImmutable( Concatenation( "insert next iterator of level ", String( next[1] ), " in priority queue ..." ) );
        Print( "insert next iterator of level ", next[1], " in priority queue ...\n" );
        InsertPriorityQueue(state.pq, next[1], next[2]);
        SignalSemaphore(sem);
        state.(name) := MakeImmutable( Concatenation( "insert next iterator of level ", String( next[1] ), " in priority queue ... DONE" ) );
        Print( "Done.\n" );
        
        ## return iterator to priority queue
        state.(name) := MakeImmutable( Concatenation( "return iterator of level ", String( prio ), " to priority queue ..." ) );
        Print( "return iterator of level ", prio, " to priority queue ...\n" );
        InsertPriorityQueue(state.pq, prio, iter);
        SignalSemaphore(sem);
        state.(name) := MakeImmutable( Concatenation( "return iterator of level ", String( prio ), " to priority queue ... DONE" ) );
        Print( "Done.\n" );
        
	state.number_of_current_jobs := state.number_of_current_jobs + 1;
        
      fi;
      
      ## the first worker who figures out that there are no jobs left
      ## (this implies that no other worker is busy) should send
      ## fail to the channel and help all workers finish by
      ## increasing the work semaphore `number_of_current_jobs' times.
      if state.number_of_current_jobs = 0 then
        SendChannel(ch, fail);
        for i in [ 1 .. state.current_number_of_workers ] do
	  SignalSemaphore(sem);
	od;
      fi;
    od;
  od;
end;

NextRecursiveIterator := function(prio, iter)
  local next;
  
  if IsDoneIterator(iter) then
    return [];
  fi;
  
  next := NextIterator(iter);
  
  if IsIterator(next) then
    return [ prio+1, next ];
  fi;
  
  return [ [ next ] ];
  
end;

EvaluateRecursiveIterator := function(state)
  local name, sem, ch, prio, iter, next, len, leaf, i;
  
  atomic state do
    state.current_number_of_workers := state.current_number_of_workers + 1;
    state.last_assigned_number := state.last_assigned_number + 1;
    name := Concatenation( "worker ", String( state.last_assigned_number ), " in thread #", String( ThreadID( CurrentThread( ) ) ) );
    sem := state.semaphore;
    ch := state.leaf_channel;
  od;
  
  SetRegionName( "", name );
  Print( "I am ", name, ". Welcome to my local thread.\n" );
  
  while true do
    atomic state do
      state.(name) := MakeImmutable( "Waiting for semaphore" );
    od;
    Print( "Waiting for semaphore ...\n" );
    WaitSemaphore(sem);
    atomic state do
      state.(name) := MakeImmutable( "Waiting for semaphore ... DONE" );
    od;
    Print( "Done.\n" );
    atomic state do
      Print( "currently ", state.number_of_current_jobs, " jobs awaiting free workers\n" );
      if state.canceled then
        iter := fail;
      else
        state.(name) := MakeImmutable( "GetPriorityQueue" );
        Print( "GetPriorityQueue ...\n" );
	iter := GetPriorityQueue(state.pq);
        state.(name) := MakeImmutable( "GetPriorityQueue ... DONE" );
        Print( "Done.\n" );
	prio := iter[1];
	iter := iter[2];
        state.(name) := MakeImmutable( "Adopt ..." );
        Print( "Adopt ...\n" );
	AdoptObj(iter);
        state.(name) := MakeImmutable( "Adopt ... DONE" );
        Print( "Done.\n" );
      fi;
    od;
    if iter = fail then
      atomic state do
        state.(name) := MakeImmutable( "Terminated!" );
      od;
      return;
    fi;
    atomic state do
      state.(name) := MakeImmutable( Concatenation( "Computing at priority level ", String( prio ), " ..." ) );
    od;
    Print( "Computing ...\n" );
    next := NextRecursiveIterator(prio, iter);
    Print( "Done.\n" );
    atomic state do
      state.(name) := MakeImmutable( Concatenation( "Computing at priority level ", String( prio ), " ... DONE" ) );
    od;
    len := Length(next);
    atomic state do
      if len = 0 then # next = [ ], the iterateor is done without producing leaves
        
        state.number_of_current_jobs := state.number_of_current_jobs - 1;
        
      elif len = 1 then # next = [ [ leaf ] ], the iterator has found a leaf
        
        ## write produced leaf to the channel
        state.(name) := MakeImmutable( "Sending a leaf to channel ..." );
        Print( "Sending a leaf to channel ...\n" );
        SendChannel(ch, next[1][1]);
        state.(name) := MakeImmutable( "Sending a leaf to channel ... DONE" );
        Print( "Done.\n" );
        
        state.number_of_leaves := state.number_of_leaves + 1;
        
        ## return iterator to priority queue
        state.(name) := MakeImmutable( Concatenation( "return iterator of level ", String( prio ), " to priority queue ..." ) );
        Print( "return iterator of level ", prio, " to priority queue ...\n" );
        InsertPriorityQueue(state.pq, prio, iter);
        SignalSemaphore(sem);
        state.(name) := MakeImmutable( Concatenation( "return iterator of level ", String( prio ), " to priority queue ... DONE" ) );
        Print( "Done.\n" );
        
      elif len = 2 then # next = [ prio, iter ] -> next task step
        
        ## insert next iterator into priority queue
        state.(name) := MakeImmutable( Concatenation( "insert next iterator of level ", String( next[1] ), " in priority queue ..." ) );
        Print( "insert next iterator of level ", next[1], " in priority queue ...\n" );
        InsertPriorityQueue(state.pq, next[1], next[2]);
        SignalSemaphore(sem);
        state.(name) := MakeImmutable( Concatenation( "insert next iterator of level ", String( next[1] ), " in priority queue ... DONE" ) );
        Print( "Done.\n" );
        
        ## return iterator to priority queue
        state.(name) := MakeImmutable( Concatenation( "return iterator of level ", String( prio ), " to priority queue ..." ) );
        Print( "return iterator of level ", prio, " to priority queue ...\n" );
        InsertPriorityQueue(state.pq, prio, iter);
        SignalSemaphore(sem);
        state.(name) := MakeImmutable( Concatenation( "return iterator of level ", String( prio ), " to priority queue ... DONE" ) );
        Print( "Done.\n" );
        
	state.number_of_current_jobs := state.number_of_current_jobs + 1;
        
      fi;
      
      ## the first worker who figures out that there are no jobs left
      ## (this implies that no other worker is busy) should send
      ## fail to the channel and help all workers finish by
      ## increasing the work semaphore `number_of_current_jobs' times.
      if state.number_of_current_jobs = 0 then
        SendChannel(ch, fail);
        for i in [ 1 .. state.current_number_of_workers ] do
	  SignalSemaphore(sem);
	od;
      fi;
    od;
  od;
end;

LaunchWorkers := function( evaluate_function, state )
  local n, i, worker;
  
  atomic state do
    n := state.maximal_number_of_workers - state.current_number_of_workers;
    for i in [ 1 .. n ] do
      worker := CreateThread(evaluate_function, state);
      Add( state.threads, worker );
    od;
  od;
end;

ParallelyEvaluateRecursiveIterator := function(state, nworkers, iter, ch)
  local sem, locally_uniform, worker, i, w;
  
  for i in NamesOfComponents( state ) do
      Unbind( state.(i) );
  od;
  
  sem := CreateSemaphore();
  
  if IsBound( iter!.locally_uniform ) and iter!.locally_uniform = true then
    locally_uniform := true;
  else
    locally_uniform := false;
  fi;
  
  state.pq := [[iter]];
  state.semaphore := sem;
  state.leaf_channel := ch;
  state.number_of_current_jobs := 1;
  state.number_of_leaves := 0;
  state.canceled := false;
  state.threads := [ ];
  state.current_number_of_workers := 0;
  state.last_assigned_number := 0;
  state.maximal_number_of_workers := nworkers;
  
  ShareInternalObj(state,"state region");
  
  if locally_uniform then
    LaunchWorkers( EvaluateLocallyUniformRecursiveIterator, state );
  else
    LaunchWorkers( EvaluateRecursiveIterator, state );
  fi;
  
  SignalSemaphore(sem);
  
  return MakeReadOnlyObj( rec(
    shutdown := function()
      atomic state do
        state.canceled := true;
        for i in [ 1 .. state.current_number_of_workers ] do
	  SignalSemaphore(sem);
	od;
	SendChannel(ch, fail);
	for w in state.threads do
	  WaitThread(w);
	od;
      od;
    end
  ));
end;

TwoLevelIterator := function(list)
  return Iterator(List(list, Iterator));
end;

ThreeLevelIterator := function(list)
  return Iterator(List(list, TwoLevelIterator));
end;
