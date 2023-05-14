-module(distribute).
-compile(export_all).

% Implement a process in a module named distribute that encapsulate two buckets which store information. The distribute process 
% receive messages on the form get_value and returns the value of one of its buckets. The return value is alternated between the 
% buckets, i.e., in the first message the value of the first bucket is returned, int the second message the second bucket, in the 
% third the first bucket and so on. Implement the function start/2 that take the value of the two buckets and return a Pid.
%      > P = distribute:start(1, 2).
%      > P ! {self(), get_value}.
%      > flush(). % value is 1
%      > P ! {self(), get_value}.
%      > flush(). % value is 2

start(Bucket1, Bucket2)->
    spawn(fun () -> distribute (Bucket1, Bucket2, 1) end).

distribute(Bucket1, Bucket2, Count) ->
    receive
        {Pid, get_value} -> 
            case (Count rem 2) of
                1 ->
                    % io:format("Pid is ~p and count is ~p ~n", [Pid , Count]),
                    Pid ! Bucket1,
                    distribute(Bucket1,Bucket2,Count+1);
                0 ->
                    % io:format("Pid is ~p and count is ~p ~n", [Pid , Count]), 
                    Pid ! Bucket2,
                    distribute(Bucket1, Bucket2, Count+1) 
            end
        end.

% distribute(Bucket1, Bucket2, Count) ->
%     receive
%         {Pid, get_value} -> 
%             io:format("Pid is ~p and count is ~p ~n", [Pid , Count])
%     end.

% In the distribute-module implement a function get/1 that safely and correctly get the value of one of the buckets. Remember to 
% ensure that we always receive the correct response in a multi-process environment. (You might have to change the format of the 
% messages).

get(Pid) ->
    Pid ! {self(), get_value},
    receive 
        Res -> Res
    end.
    