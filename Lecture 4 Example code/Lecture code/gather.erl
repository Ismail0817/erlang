-module(gather).
-compile(export_all).

master(List) ->
    Pids = [spawn_work(I) || I <- List],
    gather(Pids).

spawn_work(I) ->
    Pid = spawn(fun worker/0),
    Pid ! {self(), {work, I}},
    Pid.

worker() ->
    receive
	{Master, {work, I}} ->
	    Master ! {self(), {result, I * 2}}
    end.

gather([]) ->
    [];
gather([Pid|Pids]) ->
    receive
	{Pid, {result, R}} ->
	    [R | gather(Pids)]
    end.


