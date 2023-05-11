-module(ping_pong). 
-export([play/0]).
-compile(export_all).

play() ->
    Ping = spawn(fun ping/0), 
    spawn(fun () -> pong(Ping) end).

ping() ->
    receive 
        pong -> ok 
    end.

pong(Ping) ->
    Ping ! pong,
    receive 
        ping -> ok 
    end.

% zip_map/4 that takes four arguments: a function with two arguments (the zipper), a
% function with two arguments (the accumulator) and two lists, and returns a new value
% with the first function applied to pairs of elements of the lists. The second function then
% accumulates the results of the first function call using the specified accumulator function.
% The function should only accept lists of the same length.
% Example:
% zip_map(fun (A, B) -> A * B end,
%  fun (X, Y) -> A + B,
%  [1, 2, 3],
%  [10, 20, 30]).
% should return 140 (10*1 + 2*20 + 3*30 = 140).

zip_map(Zipper,Accumulator, L1, L2) -> zip_map(Zipper, Accumulator, L1, L2, 0).

zip_map(_Zipper, _Accumulator, [], [], Res) -> Res;
zip_map(Zipper, Accumulator, [H1|T1], [H2|T2], Res) ->
    zip_map(Zipper, Accumulator, T1, T2, Accumulator(Res,Zipper(H1,H2))).


% zip_map(Zipper, Accumulator, L1, L2) ->
%     zip_map(Zipper, Accumulator, L1, L2, 0).

% zip_map(_Zipper, _Accumulator, [], [], Res) ->
%     Res;
% zip_map(Zipper, Accumulator, [H1|T1], [H2|T2], Res) ->
%     zip_map(Zipper, Accumulator, T1, T2, Res + Accumulator(H1,H2)).

    % case Zipper(H1,H2) of
    %     true -> zip_map(Zipper, Accumulator, T1, T2, Res+Accumulator(H1+H2));
    %     false -> zip_map(Zipper, Accumulator, T1, T2, Res)
    % end.


% zip_filter/3 that takes three arguments: a function with two arguments and two lists, and returns a new list with the function 
% applied to filter the corresponding elements in the list. That is, the function is applied to pairs of elements from both lists 
% and filter (from both lists) elements for which the function returns true. The function should only accept lists of the same length.
% Example:
%      zip_filter(fun (A, B) -> A + B > 3 end, [1, 2, 3], [2, 3, 1]).
% should return the tuple {[2, 3], [3, 1]}.

pzip_filter(Fun, L1, L2) -> pzip_filter(Fun, L1, L2, length(L1)).

pzip_filter(_, [], [], Length) -> gather(Length, []);
pzip_filter(Fun, [H1 | T1], [H2 | T2], Length) ->
    Pid = spawn(fun worker/0),
    Pid ! {work, self(), Fun, H1, H2},
    pzip_filter(Fun, T1, T2, Length).



worker() -> 
    receive 
        {work, Pid, Fun, H1, H2} -> 
            case Fun(H1, H2) of 
                true -> Pid ! {ok, H1, H2};
                false -> Pid ! {not_ok}
            end
        end.

gather(0,Res) -> reverse(Res, []);
gather(Length, Res) ->
    receive 
        {ok, H1, H2} -> gather(Length - 1, [[H1,H2] | Res]);
        {not_ok} -> gather(Length-1 , Res)
    end.

reverse([], Res) -> Res;
reverse( [H | T], Res) ->
    reverse(T, [H | Res]).




