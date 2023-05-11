-module(nameserver).
-export([start/0, get/2, set/3, handle_call/2, handle_init/0]).

-behavior(gen_server1).

handle_call(State, {get, Name}) ->
    NewAddress = case ets:lookup(name_server, Name) of
		     [] ->
			 not_found;
		     [{Name, Address}] ->
			 Address
	      end,
    {reply, State, NewAddress};
handle_call(State, {set, {Name, Address}}) ->
    ets:insert(name_server, {Name, Address}),
    {reply, State, ok}.

    %% InitFun = fun () -> 

    %% 	      end,
handle_init() ->
    ets:new(name_server, [set, private, named_table]).

start() ->
    gen_server1:start(nameserver).

set(S, Name, Address) ->
    gen_server1:call(S, {set, {Name, Address}}).

get(S, Name) when is_pid(S) ->
    gen_server1:call(S, {get, Name}).
