This cookbook installs Hadoop 2.6.0 (single node cluster) on Ubuntu 14.04 and setup the system to run a simple word count python program using Hadoop Streaming API. Note that there are professionally developed cookbooks for Hadoop such as the one found at https://supermarket.chef.io/cookbooks/hadoop. This cookbook is for learning and teaching purpose and only tested on Mac.

I referred to many online tutorials and articles as found in the references section at the end of this readme - many thanks to those authors.

### Instructions
You can follow the official tutorial at https://learn.chef.io/local-development/ubuntu/ to setup Chef local development environment or just follow the links in 1 and 2 below directly.
1. Install Chef Development Kit at https://downloads.chef.io/chef-dk/mac/
2. Install virtualization tools (VirtualBox and Vagrant) at https://learn.chef.io/local-development/rhel/get-set-up/
3. run `kitchen converge` to start a Ubuntu instance and related configuration. Make sure you have fast Internet access when running this cookbook - we need to get many packages during this process, e.g., hadoop package itself is 186M. Other useful kitchen commands:
    - `kitchen create`: In this step, Test Kitchen creates an instance of your virtual environment, for example, a CentOS 7 virtual machine.
    - `kitchen converge`: In this step, Test Kitchen applies your cookbook to the virtual environment.
    - `kitchen login`: In this step, Test Kitchen creates an SSH session into your virtual environment.
    - `kitchen destroy`: In this step, Test Kitchen shuts down and destroys your virtual environment.
If things goes well, you have a Ubuntu 14.04 running with hadoop configured.
4. login by running `kitchen login`
    - `su hduser` enter 'test' as the password
    - `cd ~` go to home
    - `source ~/.bashrc` to setup environment (optional, if done, you can use `start-all.sh`, `hadoop`, `hdfs` commands without specifying the full path below)
    - `/usr/local/hadoop/sbin/start-all.sh` to start hadoop use `jps` to check
    - `/usr/local/hadoop/bin/hdfs dfs -mkdir -p /data/input` create hadoop input folder `/usr/local/hadoop/bin/hdfs dfs -rm -R /data/input` to remove
    - `/usr/local/hadoop/bin/hdfs dfs -copyFromLocal imagine.txt /data/input` copy text file to input folder
    - `/usr/local/hadoop/bin/hdfs dfs -ls /data/input` to view the input folder
    - `/usr/local/hadoop/bin/hadoop jar hadoop-streaming-2.6.0.jar -file /home/hduser/wc_mapper.py -mapper /home/hduser/wc_mapper.py -file /home/hduser/wc_reducer.py -reducer /home/hduser/wc_reducer.py -input /data/input/* -output /data/output` to run the word count python mapper and reducer
    - `/usr/local/hadoop/bin/hdfs dfs -ls /data/output` to view the output folder
    - `/usr/local/hadoop/bin/hdfs dfs -cat /data/output/part-00000` to view the word count result
    - `/usr/local/hadoop/bin/hdfs dfs -rm -R /data/output` remove the output folder first if you want to re-run the program.
    - http://localhost:50070/ you can see the WebUI, if you need to do other part-forwarding, you can edit .kitchen.yml file.
    - to shutdown the virtual Ubuntu, run `sudo poweroff`
5. if you want to wipe out everything and start with a clean slate (in case something messed up), you can simply run `kitchen destroy` and then `kitchen converge` - Note: everything on the old virtual Ubuntu is deleted.

(Optional) Install Berkshelf: if you want to revise the cookbook to use external cookbooks, you need berkshelf: `gem install berkshelf`. If you are starting a new cookbook, you can use `berks cookbook your_cookbook_name` to initialize the folder structure (no need to do this for this cookbook - I have done it for you). Refer to the following tutorial is necessary: use external cookbook:
http://docs.aws.amazon.com/opsworks/latest/userguide/cookbooks-101-opsworks-berkshelf.html#cookbooks-101-opsworks-berkshelf-vagrant
    - add external cookbook in Berksfile as `cookbook 'sudo', '~> 2.9.0'` you can go to https://supermarket.chef.io to search for a cookbook and the berkshelf information is there.
    - run `berks install` to download the external cookbook. If you are using Mac, the external cookbook is downloaded to ~/.berkshelf/cookbooks
    - specify the run list in .kitchen.yml
    - metadata.rb: this file specifies meta data for the cookbook, such as name, author, external cookbook dependencies, etc.
    - .kitchen.yml (use `kitchen init` to generate this file if not already exists): this files specifies information related to run the cookbook, such as driver (vagrant), os (ubuntu), which recipe(s) to run, and part forwarding.
    - Berksfile: this files specifies the source of external cookbooks, which is 'https://supermarket.chef.io'

### Install Hadoop on Ubuntu 14.04 Command List

If you want to manually configure hadoop, you can copy and paste the following commands:

```
sudo apt-get --assume-yes update
sudo apt-get --assume-yes install default-jdk
java -version
sudo addgroup hadoop
sudo adduser --ingroup hadoop hduser
sudo adduser hduser sudo
sudo apt-get install ssh
which ssh
which sshd
su hduser
ssh-keygen -t rsa -P ""
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys (authrized_keys is a file)
ssh localhost
cd ~
wget http://mirrors.sonic.net/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
tar xvzf hadoop-2.6.0.tar.gz
cd hadoop-2.6.0/
sudo mkdir /usr/local/hadoop
sudo mv * /usr/local/hadoop
sudo chown -R hduser:hadoop /usr/local/hadoop
update-alternatives --config java
```

`nano ~/.bashrc`, add the following to the end of the file (ctrl+o save, ctrl+x exit):

```
#HADOOP VARIABLES START
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export HADOOP_INSTALL=/usr/local/hadoop
export PATH=$PATH:$HADOOP_INSTALL/bin
export PATH=$PATH:$HADOOP_INSTALL/sbin
export HADOOP_MAPRED_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_HOME=$HADOOP_INSTALL
export HADOOP_HDFS_HOME=$HADOOP_INSTALL
export YARN_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"
#HADOOP VARIABLES END
```

```
source ~/.bashrc
which javac
readlink -f /usr/bin/javac /usr/lib/jvm/java-7-openjdk-amd64/bin/javac
```
`nano /usr/local/hadoop/etc/hadoop/hadoop-env.sh` revise: `export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64`

```
sudo mkdir -p /app/hadoop/tmp
sudo chown hduser:hadoop /app/hadoop/tmp
```

`nano /usr/local/hadoop/etc/hadoop/core-site.xml`, enter the following (hadoop temp directory and hdfs uri):

```
<configuration>
 <property>
  <name>hadoop.tmp.dir</name>
  <value>/app/hadoop/tmp</value>
  <description>A base for other temporary directories.</description>
 </property>

 <property>
  <name>fs.default.name</name>
  <value>hdfs://localhost:54310</value>
  <description>The name of the default file system.  A URI whose
  scheme and authority determine the FileSystem implementation.  The
  uri's scheme determines the config property (fs.SCHEME.impl) naming
  the FileSystem implementation class.  The uri's authority is used to
  determine the host, port, etc. for a filesystem.</description>
 </property>
</configuration>
```

```
cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
nano /usr/local/hadoop/etc/hadoop/mapred-site.xml
```
The mapred-site.xml file is used to specify which framework is being used for MapReduce.

enter the following:
```
<configuration>
 <property>
  <name>mapred.job.tracker</name>
  <value>localhost:54311</value>
  <description>The host and port that the MapReduce job tracker runs
  at.  If "local", then jobs are run in-process as a single map
  and reduce task.
  </description>
 </property>
</configuration>
```
 create two directories which will contain the namenode and the datanode for this Hadoop installation：
```
 sudo mkdir -p /usr/local/hadoop_store/hdfs/namenode
 sudo mkdir -p /usr/local/hadoop_store/hdfs/datanode
```
 `nano /usr/local/hadoop/etc/hadoop/hdfs-site.xml`, This file is used to specify the directories which will be used as the namenode and the datanode on that host, enter:

```
 <configuration>
 <property>
  <name>dfs.replication</name>
  <value>1</value>
  <description>Default block replication.
  The actual number of replications can be specified when the file is created.
  The default is used if replication is not specified in create time.
  </description>
 </property>
 <property>
   <name>dfs.namenode.name.dir</name>
   <value>file:/usr/local/hadoop_store/hdfs/namenode</value>
 </property>
 <property>
   <name>dfs.datanode.data.dir</name>
   <value>file:/usr/local/hadoop_store/hdfs/datanode</value>
 </property>
</configuration>
```

make sure to use hduser: Format the New Hadoop Filesystem

`hadoop namenode -format`

Note that hadoop namenode -format command should be executed once before we start using Hadoop.
If this command is executed again after Hadoop has been used, it'll destroy all the data on the Hadoop file system.

start hadoop: you may need to go to /usr/local/hadoop/sbin to run the following commands:

`start-all.sh` or (start-yarn.sh does not seem to start NameNode and DataNode). You may see the following messages:

```
The authenticity of host 'localhost (::1)' can't be established.
ECDSA key fingerprint is 4c:94:0a:9e:a4:69:0f:f0:e8:c9:31:ac:0d:55:ba:36.
Are you sure you want to continue connecting (yes/no)? yes

The authenticity of host '0.0.0.0 (0.0.0.0)' can't be established.
ECDSA key fingerprint is 4c:94:0a:9e:a4:69:0f:f0:e8:c9:31:ac:0d:55:ba:36.
Are you sure you want to continue connecting (yes/no)? yes
```

use jps (Java Virtual Machine Process Status Tool) to check whether hadoop is running or not：
```
$ jps
14437 NameNode
14559 DataNode
14711 SecondaryNameNode
14845 ResourceManager
15226 Jps
14942 NodeManager
```
`stop-all.sh` to stop hadoop

http://localhost:50070/ is the web UI for NameNode daemon, you need to setup port forwarding on virtualbox for 50070 and 50090 (Settings --> Network --> part forwarding)

http://localhost:50090/status.jsp check secondary namenode

http://localhost:50090/logs/ to see logs

### Other useful tips

- To copy files from Ubuntu virtualbox: go to settings, add a shared folder, login to ubuntu, go to /media/your_shared_folder (you may need to add user `sudo adduser hduser vboxsf` and then reboot `sudo reboot`)

### References

- http://www.terpconnect.umd.edu/~kpzhang/ (special thanks to my friend Kunpeng for the course materials)
- http://www.bogotobogo.com/Hadoop/BigData_hadoop_Install_on_ubuntu_single_node_cluster.php
- http://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/
