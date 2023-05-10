-module(links).
-compile(export_all).

worker(P) ->
    % fun () ->
	    Rand = rand:uniform(),
	    if Rand < 0.5 ->
		    io:format("WORKER: sucess! value = ~p~n", [100+P]);
	       true ->
		    io:format("WORKER: sucess! value = ~p~n", [P])
	    end.
    % end.

server() ->
    spawn(fun master/0).

master() ->
    process_flag(trap_exit, true),
    receive
	{work, P} ->
	    Pid = spawn_link(worker(P)),
	    io:format("sent ~p to worker with Pid=~p~n", [P, Pid]),
	    master();
	{'EXIT', Pid, Reason} ->
	    io:format("worker died ~p reason=~p~n", [Pid, Reason]),
	    master()
    end.
