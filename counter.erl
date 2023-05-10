-module(counter).
-compile(export_all).

counter() ->
    spawn(fun() -> counter_loop(0) end).

counter_loop(Value) ->
    receive
	inc ->
	    counter_loop(Value + 1);
	{count, Pid} ->
	    Pid ! Value,
	    counter_loop(Value)
    end.
