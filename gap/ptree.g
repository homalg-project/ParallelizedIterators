InstallMethod( EQ,
        [ IsRegion, IsRegion ],
        
  IsIdenticalObj );

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

PrioWorker := function(state)
  local name, sem, ch, prio, job, next, len, leaf, i;
  
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
        job := fail;
      else
        state.(name) := MakeImmutable( "GetPriorityQueue" );
        Print( "GetPriorityQueue ...\n" );
	job := GetPriorityQueue(state.pq);
        state.(name) := MakeImmutable( "GetPriorityQueue ... DONE" );
        Print( "Done.\n" );
	prio := job[1];
	job := job[2];
        state.(name) := MakeImmutable( "Adopt ..." );
        Print( "Adopt ...\n" );
	AdoptObj(job);
        state.(name) := MakeImmutable( "Adopt ... DONE" );
        Print( "Done.\n" );
      fi;
    od;
    if job = fail then
      atomic state do
        state.(name) := MakeImmutable( "Terminated!" );
      od;
      return;
    fi;
    atomic state do
      state.(name) := MakeImmutable( Concatenation( "Computing at priority level ", String( prio ), " ..." ) );
    od;
    Print( "Computing ...\n" );
    next := job[1](prio, job[2]);
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
      elif len = 2 then # next = [ prio, state ] -> next task step
        state.(name) := MakeImmutable( Concatenation( "insert next iterator of level ", String( prio ), " in priority queue ..." ) );
        Print( "popped next iterator at level ", prio, "\n" );
        Print( "insert in priority queue ...\n" );
        InsertPriorityQueue(state.pq, prio, job);
        SignalSemaphore(sem);
        InsertPriorityQueue(state.pq, next[1], [job[1], next[2]]);
        SignalSemaphore(sem);
        state.(name) := MakeImmutable( Concatenation( "insert next iterator of level ", String( prio ), " in priority queue ... DONE" ) );
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

LaunchWorkers := function( state )
  local n, i, worker;
  
  atomic state do
    n := state.maximal_number_of_workers - state.current_number_of_workers;
    for i in [ 1 .. n ] do
      worker := CreateThread(PrioWorker, state);
      Add( state.threads, worker );
    od;
  od;
end;

ScheduleWithPriority := function(state, nworkers, initial, ch)
  local worker, sem, i, w;
  
  for i in NamesOfComponents( state ) do
      Unbind( state.(i) );
  od;
  
  sem := CreateSemaphore();
  
  state.pq := [[initial]];
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
  
  LaunchWorkers( state );
  
  SignalSemaphore(sem);
  
  return MakeReadOnly( rec(
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

WithIterator := function(prio, iter)
  local next, leaves;
  if IsDoneIterator(iter) then
    return [];
  fi;
  next := NextIterator(iter);
  if IsIterator(next) then
    return [ prio+1, next ];
  else
    leaves := [ next ];
    while not IsDoneIterator(iter) do
      Add(leaves, NextIterator(iter));
    od;
    return [ leaves ];
  fi;
end;

ScheduleWithIterator := function(state, nworkers, iter, ch)
  return ScheduleWithPriority(state, nworkers, [WithIterator, iter], ch);
end;

TwoLevelIterator := function(list)
  return Iterator(List(list, Iterator));
end;

ThreeLevelIterator := function(list)
  return Iterator(List(list, TwoLevelIterator));
end;
