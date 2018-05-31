-module (socket_server_sup).

%%% @doc    

-copyright  ("Copyright © 2017-2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 14}).
-vsn        ("1.0.0").

-behaviour  (supervisor).

-export ([start_link/0]).
-export ([init/1]).

-define (SERVER, ?MODULE).
-define (SOCKET_SERVER_PORT, ?GET_ENV_INT(server_port, 8888)).
-define (SOCKET_ACCEPTOR,    ?GET_ENV(socket_acceptor, 5)).

-include ("define.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%% @todo   启动督程socket_server_sup
start_link () ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


%%% ========== ======================================== ====================
%%% callback
%%% ========== ======================================== ====================
%%% @doc    Process start callback.
init ([]) ->
    Listen      = tcp_listen(),
    ChildSpecs  = [
        begin
            ChildId = list_to_atom("socket_server_srv_" ++ integer_to_list(AcceptorId)),
            {
                ChildId, 
                {socket_server_acceptor, start_link, [ChildId, Listen]},
                transient, ?SHUTDOWN_WORKER, worker, [socket_server_acceptor]
            }
        end
        ||
        AcceptorId <- lists:seq(1, ?SOCKET_ACCEPTOR)
    ],
    
    {ok, {{one_for_one, 1, 10}, ChildSpecs}}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    TCP监听
tcp_listen () ->
    Opts = [
        binary, 
        {packet, 4}, 
        {packet_size, 1024 * 1024},
        {reuseaddr, true},
        {backlog, 1024},
        {active, false}
    ],
    case gen_tcp:listen(?SOCKET_SERVER_PORT, Opts) of
        {ok, Listen} ->
            Listen;
        {error, Reason} ->
            throw({error, {tcp_listen, Reason}})
    end.


