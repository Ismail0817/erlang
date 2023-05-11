% a) Create 4 processes, one for each of the arithmetic operations, in a module named math. Register the process under the names,
%  add, multiply, subtract, divide. Each process can receive messages on the form {ValueA, ValueB} and return the corresponding 
% result each process operation. The processes are started in a function called start/0. Try to avoid duplicating code!
%      > math:start().
%      > add ! {self(), {10, 10}}.
%      > flush(). % value is 20
%      > multiply ! {self(), {11, 2}}.
%      > flush(). % value is 22

-module(math).
-compile(export_all).


start() -> 
    register(add, spawn(fun add/0)),
    register(subtract, spawn(fun sub/0)),
    register(multiply, spawn(fun mul/0)),
    register(divide, spawn(fun divide/0)).
    

add() ->
    receive
        {Pid, {A,B}} -> 
            % io:format("received  ~p ~p ~p ~n", [Pid, A, B]),
            Pid ! A + B
    end,
    add().

sub() ->
    receive
        {Pid, {A,B}} -> Pid ! A - B
    end,
    sub().

mul() ->
    receive
        {Pid, {A,B}} -> Pid ! A * B
    end,
    mul().

divide() -> 
    receive
        {Pid, {A,B}} -> Pid ! A div B
    end,
    divide().

% b) In the math-module, add functions add/2, multiply/2, subtract/2 and divide/2 that sends messages the corresponding processes
% and return the value of the operation. Remember to ensure that you always receive the correct response. (You might have to change 
% the format of the messages).

add(A,B) ->
    add ! {self(), {A,B}},
    receive
        Res -> Res
    end.

subtract(A,B) ->
    subtract ! {self(), {A,B}},
    receive
        Res -> Res
    end.

multiply(A,B) ->
    multiply ! {self(), {A,B}},
    receive
        Res -> Res
    end.

divide(A,B) ->
    divide ! {self(), {A,B}},
    receive
        Res -> Res
    end.

% In the math-module write a function psum(Ops, Values), where Ops is a list of operation-atoms (add, mult, divi, subt) and Values 
% is a list of tuples {Value1, Value2} (assume that both lists have the same length). The function will process the values in the 
% list in parallel by sending a message to the corresponding operation process and finally gather the result by summation.
%      > math:psum([add, add, subt], [{10, 10}, {10, 10}, {0, 10}]).
%      30


% psum(Ops, Values)-> psum(Ops, Values, 0).

% psum([], [], Result) -> Result;
% psum([OH | OT], [{A,B} | VT], Result)-> 
%     case OH of
%         add -> add ! {self(), {A,B}};
%         mult -> multiply ! {self(), {A,B}};
%         divi -> divide ! {self(), {A,B}};
%         subt -> subtract ! {self(), {A,B}} 
%     end,
%     receive 
%         Res -> psum(OT, VT, Res + Result)
%     end. 

% psum(Ops, Values)-> psum(Ops, Values, length(Ops)).

% psum([], [], Length) -> gather(Length, 0);
% psum([OH | OT], [{A,B} | VT], Length)-> 
%     Pid = spawn(fun worker/0),
%     Pid ! {work, self(), OH, A, B},
%     psum(OT, VT, Length).

% worker() ->
%     receive
%         {work, Pid, Op, A, B} ->
%             case Op of 
%                 add -> add ! {Pid, {A,B}};
%                 mult -> multiply ! {Pid, {A,B}};
%                 divi -> divide ! {Pid, {A,B}};
%                 subt -> subtract ! {Pid, {A,B}} 
%             end
%         end.

% gather(0, Res) -> Res;  
% gather(Length, Res) ->
%     receive
%         Result -> gather(Length -1, Res + Result)
%     end. 

psum(Ops, Values)-> psum(Ops, Values, length(Ops)).

psum([], [], Length) -> gather(Length, 0);
psum([OH | OT], [{A,B} | VT], Length)-> 
    io:format("self pid ~p~n", [self()]),
    case OH of 
        add ->
            Pid = spawn(fun add/0),
            io:format("add created ~p~n", [Pid]),
            Pid ! {self(), {A, B}};
        mult -> 
            Pid = spawn(fun mul/0),
            % io:format("mul created ~p~n", [Pid],
            Pid ! {self(), {A, B}};
        divi -> 
            Pid = spawn(fun divide/0),
            % io:format("divi created ~p~n", [Pid]);
            Pid ! {self(), {A, B}};
        subt -> 
            Pid = spawn(fun sub/0),
            % io:format("sub created ~p~n", [Pid])
            Pid ! {self(), {A, B}} 
    end,
    psum(OT, VT, Length).


gather(0, Res) -> Res;  
gather(Length, Res) ->
    receive
        Result -> gather(Length -1, Res + Result)
    end. 