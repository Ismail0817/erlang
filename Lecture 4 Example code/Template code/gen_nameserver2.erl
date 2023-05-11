-module(gen_nameserver2).
-behaviour(gen_server2).

-compile(export_all).

handle_call(State, {get, Name}) ->
    io:format("getting~n"),
    Response = case ets:lookup(State, Name) of
		   [] ->
		       not_found;
		   [{Name, Address}] ->
		       Address
	       end,
    {reply, State, Response};
handle_call(State, {set, {Name, Address}}) ->
    io:format("setting~n"),
    ets:insert(State, {Name, Address}),
    {reply, State, ok}.

code_update(State) ->
    L = ets:tab2list(State),
    io:format("~p~n", [L]),
    State.

initial_state() ->
    ets:new(name_server, [set,private,named_table]).

stopping(Ets) ->
    io:format("killing the ets~n"),
    ets:delete(Ets),
    ok.

start() ->
    gen_server2:start(?MODULE).

stop(Pid) ->
    gen_server2:stop(Pid).

set(Pid, Name, Address) when is_pid(Pid) ->
    gen_server2:call(Pid, {set, {Name, Address}}).

get(Pid, Name) when is_pid(Pid) ->
    gen_server2:call(Pid, {get, Name}).


%% Try to restart the server more than once
%%
%% Notice that we need to do some cleanup in this implementation
%%
%% Implement one more callback stopping
test() ->
    S = gen_nameserver2:start(),
    gen_nameserver2:set(S, isak, "http://isak.com"),
    gen_nameserver2:set(S, google, "http://google.com"),
    Address = gen_nameserver2:get(S, isak),
    io:format("~p~n", [Address]),
    gen_nameserver2:stop(S).


%% Run the code, get error that ets:table badarg due to private
%% Note that:
%% 1) we don't do error handling -- need to fix this 4)
%% 2) what is the error: ets private table
%%  2.1) make it public --- oes noes
%% 3) Back to the drawing board! 
%% 3.1) fix gen_server1 and 
%% 4) back to gen_server1 fix 
