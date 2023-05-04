-module(eval).
-export([eval/1]).

eval({Op, E1, E2}) when is_atom(Op) andalso is_tuple(E1) andalso is_tuple(E2) ->
    {ok, V1} = eval(E1),
    {ok, V2} = eval(E2),
    case Op of
        add -> {ok, V1 + V2};
        sub -> {ok, V1 - V2};
        mul -> {ok, V1 * V2};
        'div' -> 
            if V2 =:= 0 ->
                error;
            true -> {ok, V1 div V2}
            end;
        _ -> error
    end;
eval({Op, E1, E2}) when is_number(E1) andalso is_number(E2) ->
    case Op of
        add -> {ok, E1 + E2};
        sub -> {ok, E1 - E2};
        mul -> {ok, E1 * E2};
        'div' ->
            if E2 =:= 0 ->
                error;
            true -> {ok, E1 div E2}
            end;
        _ -> error
    end;
eval(_) ->
    error.