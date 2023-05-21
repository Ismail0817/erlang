-module(document_processor1).
% -export([start/0, edit/2, edit/4, get/3, pending_operations/3]).
-compile(export_all).


start() ->
    Pid = spawn(fun() -> loop([]) end),
    register(loop,Pid),
    Pid.

% worker()->
%     receive
%         {FromPid, StartLine, EndLine, Fun, Doc} ->
%             ModifiedDoc = lists:sublist(Doc, StartLine) ++
%                           lists:map(Fun, lists:sublist(Doc, StartLine + 1, EndLine)) ++
%                           lists:sublist(Doc, EndLine + 1),
%             FromPid ! {ok, ModifiedDoc}
%     end.

worker()->
    receive
        {FromPid, StartLine, EndLine, Fun, Doc} ->
            ModifiedDoc = lists:sublist(Doc, 1, (StartLine+1) -1 ) ++
                          lists:map(Fun, lists:sublist(Doc, StartLine + 1, (EndLine+1) - (StartLine+1))) ++
                          lists:sublist(Doc, EndLine + 1, length(Doc)),
            FromPid ! {ok, ModifiedDoc}
    end.


loop(Doc) -> 
    receive
        {_FromPid, {edit, StartLine, EndLine, Fun}} ->
            P = spawn(fun worker/0),
            P ! {self(), StartLine, EndLine, Fun, Doc},
            io:format("Absolute value: ~p~n", [self()]),
            % loop(Doc);
            receive 
                {ok, Modified} ->
                    % FromPid ! {ok},
                    loop(Modified)
            end;
            % ModifiedDoc = lists:sublist(Doc, 1, (StartLine+1) -1 ) ++
            %               lists:map(Fun, lists:sublist(Doc, StartLine + 1, (EndLine+1) - (StartLine+1))) ++
            %               lists:sublist(Doc, EndLine + 1, length(Doc)),
            % FromPid ! {ok},
            % loop(ModifiedDoc);
        {FromPid, {get, StartLine, EndLine}} ->
            FromPid ! {ok, lists:sublist(Doc, StartLine + 1, EndLine)},
            loop(Doc);
        {FromPid, pending_operations} ->
            FromPid ! {ok, count_pending_operations(Doc)},
            loop(Doc);

        {doc, Document} -> loop(Document);
        % {modifycomplete, Modified} -> loop(Modified);
        {show, Pid} -> Pid ! Doc, loop(Doc)
    end.

edit(Doc) ->
    Doc_list = string:split(Doc, "\n"),
    loop ! {doc, Doc_list}.
    
    

edit(Pid, StartLine, EndLine, Fun) ->
    Pid ! {self(), {edit, StartLine, EndLine, Fun}},
    receive
        {ok} ->
            ok
    end.

get(Pid, StartLine, EndLine) ->
    Pid ! {self(), {get, StartLine, EndLine}},
    receive
        {ok, Result} ->
            Result
    end.
% document_processor:edit(P, 0, 1, fun (Line) ->{modify, string:uppercase(Line)} end).
pending_operations(Pid) ->
    Pid ! {self(), pending_operations},
    receive
        {ok, Count} ->
            Count
    end.

count_pending_operations(Doc) ->
    lists:foldl(fun(LineAccumulatorFun,
                     Line,
                     PendingOperationsCount) ->
                        case LineAccumulatorFun(Line) of
                            {modify,_} -> PendingOperationsCount + 1;
                            _ -> PendingOperationsCount
                        end
                end,
                fun(_) -> false end,
                Doc,
                0).
