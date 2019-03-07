-module(s).
-export([start/0, client/0, client/1, accept/1]).

start() ->
   ssl:start(),
   server(4000).

server(Port) ->
    {ok, LSocket} = ssl:listen(Port, [{certfile,"certificate.pem"}, {keyfile, "key.pem"}, binary, {reuseaddr, true}, {active, false}, {packet, 0}]),
    spawn(fun() -> accept(LSocket) end).
    
accept(LSocket) ->
  io:format("Connection start ~p~n", [self()]),
   {ok, Socket} = ssl:transport_accept(LSocket),
    ok = ssl:ssl_accept(Socket),
   Pid = spawn(fun() ->
        io:format("Connection accepted ~p~n", [Socket]),
        loop(Socket)
   end),
   ssl:controlling_process(Socket, Pid),
   accept(LSocket).

loop(Socket) ->
   ssl:setopts(Socket, [{active, once}]),
   receive
   {ssl,Socket, Data} ->
        io:format("Got packet: ~p~n~p~n", [Data, Socket]),
        ssl:send(Socket, Data),
        loop(Socket);
   {ssl_closed, Socket} ->
        io:format("Closing socket: ~p~n", [Socket]);
   Error ->
        io:format("Error on socket: ~p~n", [Error])
   end.

client() ->
  ssl:start(),
  client("Hello").

client(N) ->
    io:format("Client start: ~p~n",[self()]),
    {ok, Socket} = ssl:connect({192, 168, 2, 169}, 4000, [binary, {reuseaddr, true}, {active, false}, {packet, 0}], 3000),
    io:format("Client opened socket: ~p~n",[Socket]),
    ok = ssl:send(Socket, N),
   ssl:setopts(Socket, [{active, once}]),
    Value = receive
            {ssl,{sslsocket,new_ssl,_}, Data} ->
                io:format("Client received: ~p~n",[Data]);
            Other ->
                io:format("Client received: ~p~n",[Other])
            after 2000 ->
                0
            end,
    ssl:close(Socket),
    Value.