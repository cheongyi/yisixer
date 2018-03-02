rsync -e 'ssh -i /root/.ssh/jigu_key -p16666' -avzP /data/server/ root@hy-s0001.jigunet.com:/data/server/

http://man.linuxde.net/rsync

rsync命令是一个远程数据同步工具，可通过LAN/WAN快速同步多台主机间的文件。rsync使用所谓的“rsync算法”来使本地和远程两个主机之间的文件达到同步，这个算法只传送两个文件的不同部分，而不是每次都整份传送，因此速度相当快。 rsync是一个功能非常强大的工具，其命令也有很多功能特色选项，我们下面就对它的选项一一进行分析说明。

-e, --rsh=command 指定使用rsh、ssh方式进行数据同步。

-a, --archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD。
-v, --verbose 详细模式输出。
-z, --compress 对备份的文件在传输时进行压缩处理。
-P 等同于 --partial。
--partial 保留那些因故没有完全传输的文件，以是加快随后的再次传输。
