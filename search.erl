-module(search).
-export([search/2]).
-compile(export_all).

search(Fun, List) ->
    [X || X <- List, lists:any(Fun, X)].

psearch(F, L, MaxWorker) -> psearch(F, L, length(L), 0, MaxWorker).

psearch(_F, [], L, _CurrentWorker, _MaxWorker) -> gather([], L);

psearch(F, [H | T], L, CurrentWorker, MaxWorker)->
    Pid = spawn(fun worker/0),
    Pid ! {work, self(), H, F},
    psearch(F, T, L, CurrentWorker + 1, MaxWorker ).


worker() ->
    receive 
        {work, Pid, L, F} ->
            case lists:any(F,L) of
                true -> Pid ! {result, L};
                false -> Pid ! {resultnone, L}
            end
    end. 

gather(_Rest, 0) -> _Rest;
gather(Rest, L) -> 
    receive
        {result, Result} -> 
            gather([ Result| Rest], L-1);
        {resultnone, _Result} -> 
            gather(Rest, L-1)
    end.


% deadlock() ->
%     spawn(fun() ->
%               receive
%                   {ok, Pid, X} ->
%                       Pid ! {reply, X},
%                       receive _ -> ok end
%               end
%           end).

% deadlock() ->
%     spawn(fun() ->
%         receive
%             {ok, Pid, _X} ->
%                 Pid ! ok,
%                 deadlock()
%         end
%     end).

% deadlock() ->
%     spawn(fun() ->
%         receive
%             {ok, Pid, _X} ->
%                 Pid ! ok,
%                 deadlock()
%         end,
%         deadlock()
%     end).


deadlock() ->
    spawn(fun() ->
        receive
            {ok, Pid, _X} ->
                Pid ! ok,
                deadlock()
        end,
        receive 
            after 0 -> ok 
        end,
        deadlock()
    end).



ordered(Fun, L)-> ordered(Fun, L, length(L), 1).

ordered(_Fun, [], Length, _ListPos) -> gatherlist([], Length);
ordered(Fun, [H | T], Length, ListPos)-> 
    Pid = spawn(fun work/0),
    Pid ! {work, self(), Fun, H, ListPos},
    ordered(Fun, T, Length, ListPos +1).




work()->
    receive
        {work, Pid, Fun, Payload, ListPos} -> 
            Pid ! {result, ListPos, Fun(Payload)}
    end.

gatherlist(Res, 0) -> Res;
gatherlist(Res, Length) ->
    receive
        {result, Length, Result} -> 
            gatherlist([Result | Res], Length -1)
    end. 
