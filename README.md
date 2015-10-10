建立vagrant类型的nap，需要三步。
1，建立coreos集群
2，部署好flannel服务
3，安装nap各个组件

===============coreos集群搭建======================
1，首先不要忘记了安装vagrant和virtualbox，vagrant+vmvare也是可以的。
2，clone 这个repository。
git clone lab.artemisporjects.org/...
cd nap-vagrant
3，通过https://discovery.etcd.io/new获得一个新的etcd key，然后替换到user-data中的discovery: http:// 中。
(new method: make discovery-url)
4：启动coreos集群。vagrant up




================flannel服务启动=====================
启动之后，要部署flannel服务。我尝试着把flannel的部署写在上一步中，没有成功。主要来源于两个原因，一是coreos的flannel服务还没有直接安装在coreos系统中，没有直接的二进制文件，需要自己编译，我自己编译了，然后拷贝进去。第二个原因就是，在Vagrantfile中，通过执行脚本的形式，没有成功，感觉是需要把coreos系统都安装成功之后，启动起来，等etcd服务（flannel依赖于这个服务）等服务启动起来之后，才可以进行flannel的安装，这个后面继续尝试。

进入其中的一个机器。
vagrant ssh core-01 -- -A
cd
cd share
./flannel.sh即可。
在其余的两台机器上同样执行。
（遇到过一些问题，大部分时候执行一次.flannel.sh即可，有一些时候，会遇到一些flannel服务没有启动的问题，很奇怪的是，多执行两次这个脚本就可以了，具体原因还没有搞清楚，后面再解决。）
(find the problem. added sleep 5. flannel.service need some time to find subnet and write into /run/flannel/subnet)



=================nap组件安装=========================
这个脚本经过了多次测试，没有问题。
vagrant ssh core-01 -- -A
cd 
cd share
./component.sh


这个里面最可靠也可以说是最不可靠的就是coreos集群安装的那一部分，这个部分是coreos官网的集群安装教程。并不是每次都能正确安装集群。在集群安装完成后，可以通过一些命令验证是否成功。
vagrant ssh core-01 -- -A
fleetctl list-machines
如果这个时候，出现的是error，sorry，vagrant destroy 然后重新来过试一下。如果出现的是集群中的机器信息，很好，可以进行下一步的安装了。
