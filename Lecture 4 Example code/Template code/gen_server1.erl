-module(gen_server1).
-export([start/2, call/2, update/2]).

%% First of all, we need a way to:
%%
%% 1) Deal with the state of the server!
%% 2) Deal with differnt types of requests
%%
%% We solve both of these using functions!
%%
%% Each requests is handled by a "handler" function that takes two
%% arguments: the state of the server and the request and returns the
%% updated (possibly unchanged) state and the response

%% name_server_handler(State, {get, Name}) ->
%%     Response = case ets:lookup(State, Name) of
%% 		   [] ->
%% 		       not_found;
%% 		   [{Name, Address}] ->
%% 		       Address
%% 	       end,
%%     {reply, State, Response};
%% name_server_handler(State, {set, {Name, Address}}) ->
%%     ets:insert(State, {Name, Address}),
%%     {reply, State, ok}.

%% Then we just need to define a start function that takes as input
%% two arguments 1) the initial state and 2) the handler function

%% 1)
%% start(InitialState, Handler) ->
%%     spawn(fun () ->
%% 		  loop(InitialState, Handler)
%% 	  end).

%% 2)
start(InitialFun, Handler) ->
    spawn(fun () ->
		  loop_initial(InitialFun, Handler)
	  end).

loop_initial(InitialFun, Handler) ->
    loop(InitialFun(), Handler).

loop(State, Handler) ->
    receive
	{From, Ref, {request, Request}} ->
	    %% ADD: catch later so that we can make it crash
	    case (catch Handler(State, Request)) of
		%% add later
		{'EXIT', Reason} -> 
		    From ! {error, Ref, Reason},
		    loop(State, Handler);
		{reply, NewState, Response} ->
		    From ! {response, Ref, Response},
		    loop(NewState, Handler)			
	    end;

	%% Add this later
	{From, Ref, {update, UpdateFun}} ->
	    case UpdateFun(State) of
		{handler, NewState, NewHandler} ->
		    From ! {ok, Ref},
		    loop(NewState, NewHandler)
	    end;
	{_From, _Ref, stop} -> ok
    end.

call(S, Request) ->
    Ref = make_ref(),
    S ! {self(), Ref, {request, Request}},
    receive
	{response, Ref, Response} ->
	    Response
    end.

%% Update (add this later) after some discussion
update(S, UpdateFun) ->
    Ref = make_ref(),
    S ! {self(), Ref, {update, UpdateFun}},
    receive
	{ok, Ref} ->
	    ok
    end.

%%% We can start the server now as:
%% 
