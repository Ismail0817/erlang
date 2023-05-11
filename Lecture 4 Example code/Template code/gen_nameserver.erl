-module(gen_nameserver).

-compile(export_all).

name_server_handler(State, {get, Name}) ->
    Response = case ets:lookup(State, Name) of
		   [] ->
		       not_found;
		   [{Name, Address}] ->
		       Address
	       end,
    {reply, State, Response};
name_server_handler(State, {set, {Name, Address}}) ->
    ets:insert(State, {Name, Address}),
    {reply, State, ok}.


%% 1)
%% start() ->
%%     Ets = ets:new(name_server, [set,private,named_table]),
%%     gen_server1:start(Ets, fun name_server_handler/2).

%% 2)
start() ->
    Ets = fun () ->
		  ets:new(name_server, [set,private,named_table])
	  end,
    gen_server1:start(Ets, fun name_server_handler/2).


set(Pid, Name, Address) when is_pid(Pid) ->
    gen_server1:call(Pid, {set, {Name, Address}}).

get(Pid, Name) when is_pid(Pid) ->
    gen_server1:call(Pid, {get, Name}).


test() ->
    S = gen_nameserver:start(),
    gen_nameserver:set(S, isak, "http://isak.com"),
    Address = gen_nameserver:get(S, isak),
    io:format("~p~n", [Address]).

test_update() ->
    S = gen_nameserver:start(),
    UpdateFun = fun (_State) ->
			NewHandler = fun ({NewState, Msg}) ->
					     io:format("hello world~p~n", [Msg]),
					     {reply, NewState, ok}
				     end,
			{handler, #{}, NewHandler}
		end,
    gen_server1:update(S, UpdateFun),
    gen_nameserver:set(S, isak, "hello_world"),
    gen_nameserver:get(S, isak).

				      

%% Run the code, get error that ets:table badarg due to private
%% Note that:
%% 1) we don't do error handling -- need to fix this 4)
%% 2) what is the error: ets private table
%%  2.1) make it public --- oes noes
%% 3) Back to the drawing board! 
%% 3.1) fix gen_server1 and 
%% 4) back to gen_server1 fix 
