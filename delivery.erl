-module(delivery).
-export([test_single/0, test_multiple/0]).

test_single() ->
    P = spawn(fun echo/0),
    P ! a,
    P ! b,
    P ! c,
    ok.

test_multiple() ->
    P = spawn(fun echo/0),
    Q = spawn(fun echo/0),
    lists:foreach(fun (I) -> 
			  if 
			      I rem 2 == 0 -> P ! I; 
			      true -> Q ! I 
			  end
		  end, lists:seq(0, 10000)),
    ok.

echo() ->
    receive
	M ->
	    io:format("Echo(~p): ~p~n", [self(), M])
    end,
    echo().		    
