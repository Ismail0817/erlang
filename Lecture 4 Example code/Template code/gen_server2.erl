-module(gen_server2).
-export([start/1, call/2, update/1, stop/1]).

-callback handle_call(State :: term(), Request :: term) ->  NewState :: term().
-callback initial_state() -> State :: term().
-callback code_update(State :: term()) -> NewState :: term().
%% add later
-callback stopping(State :: term()) -> ok.


%% 2)
start(Module) ->
    spawn(fun () ->
		  loop(Module)
	  end).

loop(Module) ->
    loop(Module:initial_state(), Module).

loop(State, Module) ->
    receive
	{From, Ref, {request, Request}} ->
	    %% Deal with errors
	    case (catch Module:handle_call(State, Request)) of
		{reply, NewState, Response} ->
		    From ! {response, Ref, Response},
		    loop(NewState, Module);
		{'EXIT', Reason} ->
		    io:format("Logging: ~p~n", [Reason])
	    end;

	%% Add this laterx
	{From, Ref, update} ->
	    case Module:code_update(State) of
		NewState ->
		    From ! {ok, Ref},
		    loop(NewState, Module)
	    end;
	{_From, _Ref, stop} -> 
	    Module:stopping(State), %% add later
	    ok
    end.

call(S, Request) ->
    Ref = make_ref(),
    S ! {self(), Ref, {request, Request}},
    receive
	{response, Ref, Response} ->
	    Response
    end.

%% Update 
update(S) ->
    Ref = make_ref(),
    S ! {self(), Ref, update},
    receive
	{ok, Ref} ->
	    ok
    end.

stop(S) ->
    S ! {self(), 0, stop}.
%%% We can start the server now as:
%% 
