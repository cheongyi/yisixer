-module (wa_kuang).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 19}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([
    start/0,            % 
    read/1              % 读取文件
]).

-define (EACH_READ_LINE, 12).
-define (EACH_FRAG_FILE, 20).
-define (OUT_DIR, "./out/").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
start () ->
    read("./1111.txt").
%%% @doc    读取
read (FileName) ->
    erase(),
    filelib:ensure_dir(?OUT_DIR),
    {ok, File}      = file:open(FileName, [read]),
    loop_read(File, []),
    file:close(File).

loop_read (File, List) ->
    case update_then_read_line(File) of
        {ok, "\n"} ->
            loop_read(File, List);
        {ok, Data} ->
            RemoveData      = remove_space_tabs_newline(Data),
            [Come, Code| _] = string:tokens(RemoveData, "----"),
            % [Come | ComeRest]   = string:split(RemoveData, "----"),
            % [Code | _CodeRest]  = string:split(ComeRest, "----"),
            NewList             = [{Come, Code} | List],
            Line    = get(read_line),
            if
                Line rem ?EACH_READ_LINE == 0 ->
                    write(Line, NewList),
                    loop_read(File, []);
                true ->
                    loop_read(File, NewList)
            end;
        'eof' ->
            write(get(read_line), List);
        Other ->
            Other
    end.

write (Line, List) ->
    First   = (Line div (?EACH_READ_LINE * ?EACH_FRAG_FILE)) + if
        Line rem (?EACH_READ_LINE * ?EACH_FRAG_FILE) == 0 -> 0;
        true -> 1
    end,
    Second  = if
        Line rem (?EACH_READ_LINE * ?EACH_FRAG_FILE) == 0 -> ?EACH_FRAG_FILE;
        true -> ((Line div ?EACH_READ_LINE + if 
            Line rem ?EACH_READ_LINE == 0 -> 0; 
            true -> 1 
        end) rem ?EACH_FRAG_FILE)
    end,
    OutFileName     = ?OUT_DIR 
        ++ integer_to_list(First) 
        ++ "-"
        ++ integer_to_list(Second) 
        ++ ".txt",
    {ok, OutFile}   = file:open(OutFileName, [write]),
    write_to_file(OutFile, lists:reverse(List)),
    file:close(OutFile).

write_to_file (OutFile, [{"", _Code} | List]) ->
    write_to_file(OutFile, List);
write_to_file (OutFile, [{_Come, ""} | List]) ->
    write_to_file(OutFile, List);
write_to_file (OutFile, [{Come, Code}]) ->
    ok = file:write(OutFile, Come),
    ok = file:write(OutFile, "|"),
    ok = file:write(OutFile, Code);
write_to_file (OutFile, [{Come, Code} | List]) ->
    ok = file:write(OutFile, Come),
    ok = file:write(OutFile, "|"),
    ok = file:write(OutFile, Code),
    ok = file:write(OutFile, "\n"),
    write_to_file(OutFile, List);
write_to_file (_OutFile, []) ->
    ok.



%%% @doc    行数自增一然后读取下一行
update_then_read_line (File) ->
    update_line_number(),
    file:read_line(File).

%%% @doc    行数自增一
update_line_number () ->
    case get(read_line) of
        undefined -> put(read_line, 1);
        ReadLine  -> put(read_line, 1 + ReadLine)
    end,
    % io:format("~p(~p) ~p : ~p~n", [?MODULE, ?LINE, get(file_name), get(read_line)]),
    ok.

%%% @doc    去除空格和换行
remove_space_tabs_newline (Data) ->
    remove_space_tabs_newline(Data, ["\n"]).
remove_space_tabs_newline (Data, [RemoveChar | List]) ->
    case Data -- RemoveChar of
        Data ->
            remove_space_tabs_newline(Data, List);
        RemoveData ->
            remove_space_tabs_newline(RemoveData, [RemoveChar | List])
    end;
remove_space_tabs_newline (Data, []) ->
    Data.
