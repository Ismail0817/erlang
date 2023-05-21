-module(ping).
-compile(export_all).

ping(Ponger) ->
    Ref = monitor (process, Ponger),
    Ponger ! {ping, self()},
    receive
        pong -> 
            ping;
        {'DOWN', Ref, process, Pid, Reason} ->
            % demonitor (Ref),
            spawn(fun() -> pong_srv(0, []) end),
            % Ref = monitor (process, A),
            no_alive
            
    end.

count (Ponger) -> 
    Ponger ! {count, self()},
    receive
        N->N
    end.

ponger() ->
    spawn(fun() -> pong_srv(0, []) end).
    
pong_srv(N, ListOfPid) ->
    receive
        {ping, Pid}-> 
            Pid ! pong + 1,
        pong_srv(N + 1, [Pid | ListOfPid]);
        {count, Pid} ->
            Pid ! N,
            pong_srv(N, ListOfPid)
    end.