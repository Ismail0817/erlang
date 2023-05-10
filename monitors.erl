-module(monitors).
-compile(export_all).

on_exit(Pid, OnError) ->
    spawn(fun () ->
		  Ref = monitor(process, Pid),
		  receive
		      {'DOWN', Ref, process, _Pid, Why} ->
			  demonitor(Ref),
			  OnError(Pid, Why)
		  end		      
	  end).

reverser() ->
    receive 
	{Pid, X} ->
	    Pid ! lists:reverse(X),
	    reverser()		
    end.

			  
test_report() ->
    R = spawn(fun reverser/0),
    on_exit(R, fun (Pid, Why) -> 
		       io:format("pid: ~p failed with error: ~p~n", [Pid, Why]) 
	       end),

    on_exit(R, fun (Pid, _) -> 
		       io:format("logged error from pid: ~p~n", [Pid]) 
	       end),

    R ! {self(), [1,2,3]},
    receive 
	Reversed ->
	    io:format("~p~n", [Reversed])
    end,
    R ! {self(), abc}.
