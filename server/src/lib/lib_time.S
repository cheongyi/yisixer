{module, lib_time}.  %% version = 0

{exports, [{datetime_to_timestamp,1},
           {get_local_timestamp,0},
           {hms_tuple_to_cover0str,1},
           {module_info,0},
           {module_info,1},
           {timestamp_to_datetime,1},
           {ymd_tuple_to_cover0str,1},
           {ymd_tuple_to_cover0str,2},
           {ymdhms_integer_to_cover0str,1},
           {ymdhms_tuple_to_cover0str,1}]}.

{attributes, [{author,"CHEONGYI"},
              {date,[{2017,11,9}]},
              {vsn,"1.0.0"},
              {copyright,"Copyright © 2017 YiSiXEr"}]}.

{labels, 23}.


{function, get_local_timestamp, 0, 2}.
  {label,1}.
    {line,[{location,"lib_time.erl",38}]}.
    {func_info,{atom,lib_time},{atom,get_local_timestamp},0}.
  {label,2}.
    {allocate,0,0}.
    {line,[{location,"lib_time.erl",39}]}.
    {call_ext,0,{extfunc,erlang,now,0}}.
    {test,is_tuple,{f,3},[{x,0}]}.
    {test,test_arity,{f,3},[{x,0},3]}.
    {get_tuple_element,{x,0},0,{x,1}}.
    {get_tuple_element,{x,0},1,{x,2}}.
    {line,[{location,"lib_time.erl",40}]}.
    {gc_bif,'*',{f,0},3,[{x,1},{integer,1000000}],{x,0}}.
    {line,[{location,"lib_time.erl",40}]}.
    {gc_bif,'+',{f,0},3,[{x,0},{x,2}],{x,0}}.
    {deallocate,0}.
    return.
  {label,3}.
    {line,[{location,"lib_time.erl",39}]}.
    {badmatch,{x,0}}.


{function, datetime_to_timestamp, 1, 5}.
  {label,4}.
    {line,[{location,"lib_time.erl",45}]}.
    {func_info,{atom,lib_time},{atom,datetime_to_timestamp},1}.
  {label,5}.
    {allocate,0,1}.
    {line,[{location,"lib_time.erl",46}]}.
    {call_ext,1,{extfunc,erlang,localtime_to_universaltime,1}}.
    {line,[{location,"lib_time.erl",47}]}.
    {call_ext,1,{extfunc,calendar,datetime_to_gregorian_seconds,1}}.
    {line,[{location,"lib_time.erl",47}]}.
    {gc_bif,'-',{f,0},1,[{x,0},{integer,62167219200}],{x,0}}.
    {deallocate,0}.
    return.


{function, timestamp_to_datetime, 1, 7}.
  {label,6}.
    {line,[{location,"lib_time.erl",51}]}.
    {func_info,{atom,lib_time},{atom,timestamp_to_datetime},1}.
  {label,7}.
    {allocate,0,1}.
    {line,[{location,"lib_time.erl",53}]}.
    {gc_bif,'+',{f,0},1,[{x,0},{integer,62167219200}],{x,0}}.
    {line,[{location,"lib_time.erl",53}]}.
    {call_ext,1,{extfunc,calendar,gregorian_seconds_to_datetime,1}}.
    {line,[{location,"lib_time.erl",52}]}.
    {call_ext_last,1,{extfunc,erlang,universaltime_to_localtime,1},0}.


{function, ymdhms_integer_to_cover0str, 1, 9}.
  {label,8}.
    {line,[{location,"lib_time.erl",58}]}.
    {func_info,{atom,lib_time},{atom,ymdhms_integer_to_cover0str},1}.
  {label,9}.
    {test,is_lt,{f,10},[{x,0},{integer,10}]}.
    {allocate,0,1}.
    {line,[{location,"lib_time.erl",59}]}.
    {call_ext,1,{extfunc,erlang,integer_to_list,1}}.
    {test_heap,2,1}.
    {put_list,{integer,48},{x,0},{x,0}}.
    {deallocate,0}.
    return.
  {label,10}.
    {line,[{location,"lib_time.erl",61}]}.
    {call_ext_only,1,{extfunc,erlang,integer_to_list,1}}.


{function, ymdhms_tuple_to_cover0str, 1, 12}.
  {label,11}.
    {line,[{location,"lib_time.erl",64}]}.
    {func_info,{atom,lib_time},{atom,ymdhms_tuple_to_cover0str},1}.
  {label,12}.
    {test,is_tuple,{f,11},[{x,0}]}.
    {test,test_arity,{f,11},[{x,0},2]}.
    {allocate,1,1}.
    {get_tuple_element,{x,0},1,{y,0}}.
    {get_tuple_element,{x,0},0,{x,0}}.
    {line,[{location,"lib_time.erl",65}]}.
    {call,1,{f,14}}.
    {move,{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {move,{x,1},{y,0}}.
    {line,[{location,"lib_time.erl",65}]}.
    {call,1,{f,18}}.
    {test_heap,2,1}.
    {put_list,{integer,32},{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {line,[{location,"lib_time.erl",65}]}.
    {call_ext_last,2,{extfunc,erlang,'++',2},1}.


{function, ymd_tuple_to_cover0str, 1, 14}.
  {label,13}.
    {line,[{location,"lib_time.erl",68}]}.
    {func_info,{atom,lib_time},{atom,ymd_tuple_to_cover0str},1}.
  {label,14}.
    {test,is_tuple,{f,13},[{x,0}]}.
    {test,test_arity,{f,13},[{x,0},3]}.
    {allocate,2,1}.
    {get_tuple_element,{x,0},1,{y,0}}.
    {get_tuple_element,{x,0},2,{y,1}}.
    {get_tuple_element,{x,0},0,{x,0}}.
    {line,[{location,"lib_time.erl",69}]}.
    {call_ext,1,{extfunc,erlang,integer_to_list,1}}.
    {move,{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {move,{x,1},{y,0}}.
    {line,[{location,"lib_time.erl",70}]}.
    {call,1,{f,9}}.
    {move,{x,0},{x,1}}.
    {move,{y,1},{x,0}}.
    {move,{x,1},{y,1}}.
    {line,[{location,"lib_time.erl",71}]}.
    {call,1,{f,9}}.
    {test_heap,2,1}.
    {put_list,{integer,45},{x,0},{x,1}}.
    {move,{y,1},{x,0}}.
    {kill,{y,1}}.
    {line,[{location,"lib_time.erl",71}]}.
    {call_ext,2,{extfunc,erlang,'++',2}}.
    {test_heap,2,1}.
    {put_list,{integer,45},{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {line,[{location,"lib_time.erl",70}]}.
    {call_ext_last,2,{extfunc,erlang,'++',2},2}.


{function, ymd_tuple_to_cover0str, 2, 16}.
  {label,15}.
    {line,[{location,"lib_time.erl",72}]}.
    {func_info,{atom,lib_time},{atom,ymd_tuple_to_cover0str},2}.
  {label,16}.
    {test,is_tuple,{f,15},[{x,0}]}.
    {test,test_arity,{f,15},[{x,0},3]}.
    {allocate,3,2}.
    {get_tuple_element,{x,0},1,{y,0}}.
    {get_tuple_element,{x,0},2,{y,1}}.
    {get_tuple_element,{x,0},0,{x,0}}.
    {move,{x,1},{y,2}}.
    {line,[{location,"lib_time.erl",73}]}.
    {call_ext,1,{extfunc,erlang,integer_to_list,1}}.
    {move,{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {move,{x,1},{y,0}}.
    {line,[{location,"lib_time.erl",74}]}.
    {call,1,{f,9}}.
    {move,{x,0},{x,1}}.
    {move,{y,1},{x,0}}.
    {move,{x,1},{y,1}}.
    {line,[{location,"lib_time.erl",75}]}.
    {call,1,{f,9}}.
    {move,{x,0},{x,1}}.
    {move,{y,2},{x,0}}.
    {line,[{location,"lib_time.erl",75}]}.
    {call_ext,2,{extfunc,erlang,'++',2}}.
    {move,{x,0},{x,1}}.
    {move,{y,1},{x,0}}.
    {kill,{y,1}}.
    {line,[{location,"lib_time.erl",75}]}.
    {call_ext,2,{extfunc,erlang,'++',2}}.
    {move,{x,0},{x,1}}.
    {move,{y,2},{x,0}}.
    {kill,{y,2}}.
    {line,[{location,"lib_time.erl",74}]}.
    {call_ext,2,{extfunc,erlang,'++',2}}.
    {move,{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {line,[{location,"lib_time.erl",74}]}.
    {call_ext_last,2,{extfunc,erlang,'++',2},3}.


{function, hms_tuple_to_cover0str, 1, 18}.
  {label,17}.
    {line,[{location,"lib_time.erl",78}]}.
    {func_info,{atom,lib_time},{atom,hms_tuple_to_cover0str},1}.
  {label,18}.
    {test,is_tuple,{f,17},[{x,0}]}.
    {test,test_arity,{f,17},[{x,0},3]}.
    {allocate,2,1}.
    {get_tuple_element,{x,0},1,{y,0}}.
    {get_tuple_element,{x,0},2,{y,1}}.
    {get_tuple_element,{x,0},0,{x,0}}.
    {line,[{location,"lib_time.erl",79}]}.
    {call,1,{f,9}}.
    {move,{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {move,{x,1},{y,0}}.
    {line,[{location,"lib_time.erl",80}]}.
    {call,1,{f,9}}.
    {move,{x,0},{x,1}}.
    {move,{y,1},{x,0}}.
    {move,{x,1},{y,1}}.
    {line,[{location,"lib_time.erl",81}]}.
    {call,1,{f,9}}.
    {test_heap,2,1}.
    {put_list,{integer,58},{x,0},{x,1}}.
    {move,{y,1},{x,0}}.
    {kill,{y,1}}.
    {line,[{location,"lib_time.erl",81}]}.
    {call_ext,2,{extfunc,erlang,'++',2}}.
    {test_heap,2,1}.
    {put_list,{integer,58},{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {line,[{location,"lib_time.erl",80}]}.
    {call_ext_last,2,{extfunc,erlang,'++',2},2}.


{function, module_info, 0, 20}.
  {label,19}.
    {line,[]}.
    {func_info,{atom,lib_time},{atom,module_info},0}.
  {label,20}.
    {move,{atom,lib_time},{x,0}}.
    {line,[]}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 22}.
  {label,21}.
    {line,[]}.
    {func_info,{atom,lib_time},{atom,module_info},1}.
  {label,22}.
    {move,{x,0},{x,1}}.
    {move,{atom,lib_time},{x,0}}.
    {line,[]}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.
