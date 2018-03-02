-module (fifo_types).

-author ("CHEONGYI").

-export ([new/0, push/2, pop/1, empty/1]).
-export ([test/0]).

-spec new() -> {fifo, [], []}.
new () ->
    {fifo, [], []}.

-spec push({fifo, In::list(), Out::list()}, term()) -> {fifo, list(), list()}.
push ({fifo, In, Out}, X) ->
    {fifo, [X | In], Out}.

-spec pop({fifo, In::list(), Out::list()}) -> {term(), {fifo, list(), list()}}.
pop ({fifo, [], []}) ->
    erlang:error('empty fifo');
pop ({fifo, In, []}) ->
    pop({fifo, [], lists:reverse(In)});
pop ({fifo, In, [X | Out]}) ->
    {X, {fifo, In, Out}}.

-spec empty({fifo, [], []}) -> true;
           ({fifo, nonempty_list(), nonempty_list()}) -> false.
empty ({fifo, [], []}) ->
    true;
empty ({fifo, _In, _Out}) ->
    false.

test () ->
    N = new(),
    {2, N2} = pop(push(push(N, 2), 5)),
    {5, N3} = pop(N2),
    N = N3,
    true = empty(N3),
    false = empty(N2),
    pop({fifo, [a | "b"], [c]}).