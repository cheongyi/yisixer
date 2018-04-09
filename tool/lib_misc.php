<?php
// =========== ======================================== ====================
// @todo   生成填补字符
function generate_char ($max_length, $length, $char) {
    $space      = "";
    $fill_len   = $max_length - $length;
    for ($i = 0; $i < $fill_len; $i ++) {
        $space .= $char;
    }
     
    return $space;
}


// @todo    写入属性
function write_attributes($file) {
    $year   = date("Y");
    $ymd    = date("Y, m, d");
    fwrite($file, "

%%% @doc    

-copyright  (\"Copyright © 2017-$year YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({{$ymd}}).
-vsn        (\"1.0.0\").
");
}

?>