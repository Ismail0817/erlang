-module(nameserver).
-compile(export_all).

%% Perhaps: register nameserver
%% but I think it is better to be explicit
server() ->
    spawn(fun name_server/0).

name_server() ->
    ets:new(name_server, [set,private,named_table]),
    loop().

loop() ->
    receive
	{Pid, Ref, {set, {Name, Address}}} ->
	    ets:insert(name_server, {Name, Address}),
	    Pid ! {ok, Ref};	
	{_Pid, _Ref, stop} ->
	    ok;
	{Pid, Ref, {get, Name}} ->
	    case ets:lookup(name_server, Name) of
		[] ->
		    Pid ! {not_found, Ref};
		[{Name, Address}] ->
		    Pid ! {ok, Ref, Address}
	    end
    end,
    loop().

set(Pid, Name, Address) when is_pid(Pid) ->
    Ref = make_ref(),
    Pid ! {self(), Ref, {set, {Name, Address}}},
    receive
	{ok, Ref} ->
	    ok
    after 1000 ->
	    error
    end.

get(Pid, Name) when is_pid(Pid) ->
    Ref = make_ref(),
    Pid ! {self(), Ref, {get, Name}},
    receive
	{not_found, Ref} ->
	    not_found;
	{ok, Ref, Address} ->
	    Address
    end.

%%% Show lecture slides on untagged messages!
%% Change get, set (client, and server)
%% make_ref(), send ref, receive ref, resend ref, receive ref
