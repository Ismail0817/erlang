-module(pingpong).
-compile(export_all).

ping(To) ->
    To ! {ping, self()},
    receive
	pong ->
	    io:format("got pong~n")
    end.
    

ponger() ->
    spawn(fun ponger_loop/0).

ponger_loop() ->
    receive
	{ping, Pid} ->
	    Pid ! pong,
	    ponger_loop()
    end.
