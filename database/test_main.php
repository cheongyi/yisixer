<?php
print_r($_SERVER);
echo $_SERVER ."\n";
echo date("Y") ."\n";

echo "请选择一个操作：
  1 - 生成代码(服务端)
  2 - 编译项目(服务端)
  3 - 生成代码(客户端)
  4 - 更新数据库
  x - 退出
> ";

echo shell_exec("date");

$link = mysqli_connect("127.0.0.1", "root", "wlwlwl", "gamedb", 3306);

if (mysqli_connect_errno()) {

        printf("Connect failed: %s\n", mysqli_connect_error());

        exit();

}

$quick = true;

$query_type = $quick ? MYSQLI_USE_RESULT : MYSQLI_STORE_RESULT;

$sql = "select * from db_version";

$qrs = mysqli_query($link, $sql, $query_type);

/*先注释掉这段

$sql_ex = "delete from tbl_xx where xx";

$ret = mysqli_query($link,$sql_ex);

if (!$ret)

{

 printf("Error:%s\n",mysqli_error($link));

}

*/

var_dump($qrs);

$rows =array();

while(($row= mysqli_fetch_array($qrs, MYSQLI_ASSOC))!=null)

{

        $rows[]=$row;

}

mysqli_free_result($qrs);

mysqli_close($link);

?>