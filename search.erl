-module(search).
-export([search/2]).

search(Fun, List) ->
    [X || X <- List, lists:any(Fun, X)].