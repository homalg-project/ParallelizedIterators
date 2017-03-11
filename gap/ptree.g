CreatePriorityQueue := function()
  return [];
end;

InsertPriorityQueue := function(pq, prio, elem)
  local k, l;
  l := Length(pq);
  k := l;
  while k > 0 and prio < pq[k][1] do
    pq[k+1] := pq[k];
    k := k - 1;
  od;
  pq[k+1] := MigrateObj([prio, elem], pq);
end;

GetPriorityQueue := function(pq)
  local len, result;
  len := Length(pq);
  if len = 0 then
    return [fail, fail];
  fi;
  result := pq[len];
  Unbind(pq[len]);
  return result;
end;

PrioWorker := function(state, sem, ch, nworkers)
  local prio, job, next, len, leaf, i;
  while true do
    WaitSemaphore(sem);
    atomic state do
      if state.cancelled then
        job := fail;
      else
	job := GetPriorityQueue(state.pq);
	AdoptObj(job);
	prio := job[1];
	job := job[2];
      fi;
    od;
    if job = fail then
      return;
    fi;
    next := job[1](prio, job[2]);
    len := Length(next);
    atomic state do
      if len = 0 then # Empty
        state.count := state.count - 1;
      elif len = 1 then # [ [ leaves ] ]
        for leaf in next[1] do
	  SendChannel(ch, leaf);
	od;
	state.count := state.count - 1;
      elif len = 2 then # [ prio, state] -> next task step
        InsertPriorityQueue(state.pq, prio, job);
	SignalSemaphore(sem);
        InsertPriorityQueue(state.pq, next[1], [job[1], next[2]]);
	SignalSemaphore(sem);
	state.count := state.count + 1;
      elif len = 3 then # [ prio, func, state ] -> next task step
        InsertPriorityQueue(state.pq, prio, job);
	SignalSemaphore(sem);
        InsertPriorityQueue(state.pq, next[1], next{[2..3]});
	SignalSemaphore(sem);
	state.count := state.count + 1;
      fi;
      if state.count = 0 then
        SendChannel(ch, fail);
        for i in [1..nworkers] do
	  SignalSemaphore(sem);
	od;
      fi;
    od;
  od;
end;

ScheduleWithPriority := function(nworkers, prio, initial, ch)
  local state, workers, sem, i;
  state := rec(
    pq := [[prio,initial]],
    count := 1,
    nworkers := nworkers,
    cancelled := false
  );
  ShareInternalObj(state);
  sem := CreateSemaphore();
  workers := [];
  for i in [1..nworkers] do
    workers[i] := CreateThread(PrioWorker, state, sem, ch, nworkers);
  od;
  SignalSemaphore(sem);
  for i in [1..nworkers] do
    WaitThread(workers[i]);
  od;
  return function()
    atomic state do
      state.cancelled := true;
      for i in [1..state.nworkers] do
        SignalSemaphore(sem);
      od;
    od;
    SendChannel(ch, fail);
  end;
end;

WithIterator := function(prio, iter)
  local next, leaves;
  if IsDoneIterator(iter) then
    return [];
  fi;
  next := NextIterator(iter);
  if IsIterator(next) then
    prio[2] := prio[2] + 1;
    return [ [prio[1]+1, 1], next ];
  else
    leaves := [ next ];
    while not IsDoneIterator(iter) do
      Add(leaves, NextIterator(iter));
    od;
    return [ leaves ];
  fi;
end;

ScheduleWithIterator := function(nworkers, iter, ch)
  return ScheduleWithPriority(nworkers, [ 0, 0 ], [WithIterator, iter], ch);
end;

TwoLevelIterator := function(list)
  return Iterator(List(list, Iterator));
end;

iter_channel := CreateChannel();
sample_iter := TwoLevelIterator([[1,2,3],[4,5,6],[7,8,9]]);
cancel := ScheduleWithIterator(4, sample_iter, iter_channel);
while true do
  elem := ReceiveChannel(iter_channel);
  if elem = fail then break; fi;
  Display(elem);
od;
