-module (reloader).

-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-behaviour (gen_server).

-export ([start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    all_changed/0,
    is_changed/1,
    reload_modules/1
]).

-include ("define.hrl").
-include_lib ("kernel/include/file.hrl").

-record (state, {last, tref}).



%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> {ok, pid()}.
%%% @doc    Start the reloader and link gen_server.
start_link () ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%% @spec stop() -> ok.
%%% @doc Stop the reloader.
stop () ->
    gen_server:call(?MODULE, stop).


%%% ========== ======================================== ====================
%%% gen_server callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    if
        ?IS_DEBUG ->
            {ok, TRef} = timer:send_interval(timer:seconds(2), doit),
            {ok, #state{last = erlang:localtime(), tref = TRef}};
        true ->
            {ok, #state{last = erlang:localtime()}}
    end.

%%% @spec   handle_call(Args, From, State) -> tuple().
%%% @doc    gen_server:call callback.
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (_Req, _From, State) ->
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple().
%%% @doc    gen_server:cast callback.
handle_cast (_Req, State) ->
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple().
%%% @doc    reloader ! Msg callback.
handle_info (doit, State) ->
    DateTimeTuple = erlang:localtime(),
    doit(State#state.last, DateTimeTuple),
    {noreply, State#state{last = DateTimeTuple}};
handle_info (_Info, State) ->
    {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok.
%%% @doc    gen_server termination callback.
terminate (_Reason, State) ->
    catch timer:cancel(State#state.tref),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> {ok, State}.
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   reload_modules([atom()]) -> [{module, atom()} | {error, term()}].
%%% @doc    code:purge/1 and code:load_file/1 the given list of modules in order,
%%%      return the results of code:load_file/1.
reload_modules (ModuleList) ->
    [begin code:purge(Module), code:load_file(Module) end || Module <- ModuleList].

%%% @spec all_changed() -> [atom()].
%%% @doc Return a list of beam modules that have changed.
all_changed () ->
    [Module || {Module, FileName} <- code:all_loaded(), is_list(FileName) andalso is_changed(Module)].

%%% @spec   is_changed(atom()) -> boolean().
%%% @doc    true if the loaded module is a beam with a vsn attribute
%%%      and does not match the on-disk beam file, returns false otherwise.
is_changed (Module) ->
    try module_vsn(Module:module_info(attributes)) =/= module_vsn(code:get_object_code(Module))
    catch 
        _:_ ->
            false
    end.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    获取模块版本号
module_vsn ({Module, Beam, _FileName}) ->
    {ok, {Module, Vsn}} = beam_lib:version(Beam),
    Vsn;
module_vsn (AttrList) when is_list(AttrList) ->
    {_, Vsn} = lists:keyfind(vsn, 1, AttrList),
    Vsn.

%%% @doc    载入新编译文件
doit (Last, Now) ->
    doit_4(Last, Now, code:all_loaded(), false).
doit_4 (_Last, _Now, [], IsReload) ->
    if
        IsReload ->
            io:format("~nReloading done!~n", []);
        true ->
            ok
    end;
doit_4 (Last, Now, [{Module, FileName} | AllLoadedList], IsReload) when is_list(FileName) ->
    Result = case file:read_file_info(FileName) of
        {ok, #file_info{mtime = MTime}} when MTime >= Last andalso MTime < Now ->
            reload(Module);
        {ok, _} ->
            unmodified;
        {error, enoent} ->
            %%% The Erlang compiler deletes existing .beam files if
            %%% recompiling fails.  Maybe it's worth spitting out a
            %%% warning here, but I'd want to limit it to just once.
            gone;
        {error, Reason} ->
            ?ERROR("Error reading ~s's file info: ~p~n", [FileName, Reason]),
            error
    end,
    NewIsReload = if
        Result == reload orelse
        Result == reload_but_test_failed ->
            true;
        true ->
            IsReload
    end,
    doit_4(Last, Now, AllLoadedList, NewIsReload);
doit_4 (Last, Now, [_| AllLoadedList], IsReload) ->
    doit_4(Last, Now, AllLoadedList, IsReload).

%%% @doc    重新载入模块
reload (Module) ->
    io:format("~nReloading ~p ", [Module]),
    io:format(string:copies(".", 43 - length(atom_to_list(Module)))),
    code:purge(Module),
    case code:load_file(Module) of
        {module, Module} ->
            io:format(" ok."),
            case erlang:function_exported(Module, test, 0) of
                true ->
                    io:format("~n - Calling ~p:test() ...", [Module]),
                    case catch Module:test() of
                        ok ->
                            io:format(" ok."),
                            reload;
                        Reason ->
                            io:format(" fail: ~p.~n", [Reason]),
                            reload_but_test_failed
                    end;
                false ->
                    reload
            end;
        {error, Reason} ->
            io:format(" fail: ~p.~n", [Reason]),
            error
    end.



