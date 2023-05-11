-module(gen_server1).
-export([start/1, call/2]).

-callback handle_call(State :: term(), Request :: term()) -> {reply, NewState :: term(), Response :: term()}.
-callback handle_init() -> State :: term().

start(Module) ->
    spawn(fun () ->
		  loop(Module:handle_init(), Module)
	  end).

loop(State, Module) ->
    receive
	{From, Ref, {request, Request}} ->
	    case Module:handle_call(State, Request) of
		{reply, NewState, Response} ->
		    From ! {response, Ref, Response},
		    loop(NewState, Module)
	    end
    end.
			
call(S, Request) ->
    Ref = make_ref(),
    S ! {self(), Ref, {request, Request}},
    receive
	{response, Ref, Response} ->
	    Response
    end.	    
    
