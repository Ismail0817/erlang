-module(document_processor).
% -export([start/0, edit/2, edit/4, get/3, pending_operations/3]).
-compile(export_all).


start() ->
    Pid = spawn(fun() -> loop([]) end),
    register(loop,Pid),
    Pid.

loop(Doc) -> 
    receive
        {FromPid, {edit, StartLine, EndLine, Fun}} ->
            ModifiedDoc = lists:sublist(Doc, StartLine) ++
                          lists:map(Fun, lists:sublist(Doc, StartLine + 1, EndLine)) ++
                          lists:sublist(Doc, EndLine + 1),
            FromPid ! {ok},
            loop(ModifiedDoc);
        {FromPid, {get, StartLine, EndLine}} ->
            FromPid ! {ok, lists:sublist(Doc, StartLine + 1, EndLine)},
            loop(Doc);
        % {FromPid, pending_operations} ->
        %     FromPid ! {ok, count_pending_operations(Doc)},
        %     loop(Doc)

        {doc, Document} -> loop(Document);
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

% pending_operations(Pid) ->
%     Pid ! {self(), pending_operations},
%     receive
%         {ok, Count} ->
%             Count
%     end.

% count_pending_operations(Doc) ->
%     lists:foldl(fun(LineAccumulatorFun,
%                      Line,
%                      PendingOperationsCount) ->
%                         case LineAccumulatorFun(Line) of
%                             {modify,_} -> PendingOperationsCount + 1;
%                             _ -> PendingOperationsCount
%                         end
%                 end,
%                 fun(_) -> false end,
%                 Doc,
%                 0).
