<?php
// (1). 来自网络的ANSI属性控制码: 
// \033[0m                 关闭所有属性
// \033[1m                 设置高亮度
// \033[4m                 下划线
// \033[5m                 闪烁
// \033[7m                 反显
// \033[8m                 消隐
// \033[30m -- \033[37m    设置前景色
// \033[40m -- \033[47m    设置背景色
// \033[nA                 光标上移n行
// \033[nB                 光标下移n行
// \033[nC                 光标右移n列
// \033[nD                 光标左移n列
// \033[y;H                设置光标位置
// \033[2J                 清屏
// \033[K                  清除从光标到行尾的内容
// \033[s                  保存光标位置
// \033[u                  恢复光标位置
// \033[?25l               隐藏光标
// \033[?25h               显示光标
// (2). 文字背景色彩数字: (颜色范围:40 - 49)
// 40:    黑色
// 41:    深红色
// 42:    绿色
// 43:    黄色
// 44:    蓝色
// 45:    紫色
// 46:    深绿色
// 47:    白色

// (3). 文字前景色数字: (颜色范围: 30 - 39)
// 30:    黑色
// 31:    红色
// 32:    绿色
// 33:    黄色
// 34:    蓝色
// 35:    紫色
// 36:    深绿色
// 37:    白色
    $rotate = array("|", "/", "-", "\\");
    for ($i = 0; $i <= 50; $i++) {
        // printf("mprogress: %d%% %s\r", $i * 2, str_repeat('#',$i) );
        printf("\033[?25l[%s][\033[1m%d%%\033[0m]\033[42m%s\033[0m\r", 
            $rotate[$i % 4],
            $i * 2,
            str_repeat(' ',$i)
        );
        usleep(1000 * 100);
    }
    echo "\n", "Done.\n\033[?25h";
?>
