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

PrioWorker := function(state, sem, ch, nworkers, name)
  local prio, job, next, len, leaf, i;
  name := Concatenation( "worker", name );
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
      if state.cancelled then
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
      ## increasing the work semaphore `nworkers' times.
      if state.number_of_current_jobs = 0 then
        SendChannel(ch, fail);
        for i in [1..nworkers] do
	  SignalSemaphore(sem);
	od;
      fi;
    od;
  od;
end;

ScheduleWithPriority := function(state, nworkers, initial, ch)
  local workers, sem, i, w;
  
  for i in NamesOfComponents( state ) do
      Unbind( state.(i) );
  od;
  
  state.pq := [[initial]];
  state.number_of_current_jobs := 1;
  state.cancelled := false;
  
  ShareInternalObj(state,"state region");
  
  sem := CreateSemaphore();
  
  workers := [];
  for i in [1..nworkers] do
    workers[i] := CreateThread(PrioWorker, state, sem, ch, nworkers, String( i ));
  od;
  SignalSemaphore(sem);
  return MakeReadOnly( rec(
    workers := workers,
    shutdown := function()
      atomic state do
	state.cancelled := true;
	for i in [1..nworkers] do
	  SignalSemaphore(sem);
	od;
	SendChannel(ch, fail);
	for w in workers do
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
