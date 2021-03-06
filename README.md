This cookbook contains a number of recipes to setup a few systems for big data analytics. Note that there are professionally developed cookbooks for setting up those systems that can be found at https://supermarket.chef.io/. This cookbook is for learning and teaching purpose and only tested on Mac. I try to add comments to the recipes to document the commands - I highly recommend reading the recipes to learn the installation and configuration details. I referred to many online tutorials and articles as found in the references section at the end of this README - many thanks to those authors.

- Hadoop: hadoop recipe installs Hadoop 2.6.0 (single node cluster) on Ubuntu 14.04 and configures the system to run a simple word count python program (counting the words in the lyrics of the song "[Imagine](https://www.youtube.com/watch?v=DVg2EJvvlF8)" by John Lennon) using Hadoop Streaming API.
- Spark: spark recipe installs spark 1.6.0. pre-built for Hadoop 2.6 and later.
- HBase: hbase recipe installs hbase 1.1.5.
- Hive: hive recipe installs hive 2.0.0 with Derby as the metadata store


### Instructions
You can follow the official tutorial at https://learn.chef.io/local-development/ubuntu/ to setup Chef local development environment or just follow the links in 1 and 2 below directly. For a brief introduction about the folder structure, see next section.

1. Install Chef Development Kit at https://downloads.chef.io/chef-dk/mac/

2. Install virtualization tools (VirtualBox and Vagrant) at https://learn.chef.io/local-development/rhel/get-set-up/

3. Use cookbook dependency manager Berkshelf to download external cookbooks: run `berks install` to download the external cookbook. If you are using Mac, the external cookbooks are downloaded to ~/.berkshelf/cookbooks. For example, I use java cookbook (https://supermarket.chef.io/cookbooks/java) to install Oracle Java 7 - you can change the attributes in .kitchen.yml file (such as java version, etc).

4. Configuration (optional): the default system setting for this cookbook can be found in .kitchen.yml: Ubuntu 14.04, 2G RAM (512M is fine to run Hadoop example, more is need for Spark), some part forwarding settings. By default, this cookbook installs a few systems. If you want to setup a subset of the systems, you need to comment out the corresponding recipes in /recipes/default.rb.

5. run `kitchen converge` to start a Ubuntu instance and related configuration. Make sure you have fast Internet access when running this cookbook - we need to get many packages during this process, e.g., hadoop package itself is 186M. If things goes well, you have a Ubuntu 14.04 running with hadoop configured.

    Other useful kitchen commands:
    - `kitchen create`: Test Kitchen creates an instance of your virtual environment, for example, a Ubuntu 14.04 virtual machine.
    - `kitchen converge`: Test Kitchen applies your cookbook to the virtual environment, it also creates an instance if not already existed.
    - `kitchen login`: Test Kitchen creates an SSH session into your virtual environment.
    - `kitchen destroy`: Test Kitchen shuts down and destroys your virtual environment.

6. login by running `kitchen login`

    You need to login as the dbuser:
    - `su bduser` enter 'test' as the password
    - `cd ~` go to home

    For Hadoop:
    - `start-dfs.sh` and `start-yarn.sh` to start hadoop use `jps` to check
    - `hdfs dfs -mkdir -p /data/input` create hadoop input folder `hdfs dfs -rm -R /data/input` to remove
    - `hdfs dfs -copyFromLocal ./data/imagine.txt /data/input` copy text file to input folder
    - `hdfs dfs -ls /data/input` to view the input folder
    - `hadoop jar hadoop-streaming-2.6.0.jar -mapper /home/bduser/programs/hadoop/wc_mapper.py -reducer /home/bduser/programs/hadoop/wc_reducer.py -input /data/input/* -output /data/output` to run the word count python mapper and reducer
    - `hdfs dfs -ls /data/output` to view the output folder
    - `hdfs dfs -cat /data/output/part-00000` to view the word count result
    - `hdfs dfs -rm -R /data/output` remove the output folder first if you want to re-run the program.
    - http://localhost:50070/ you can see the WebUI, if you need to do other part-forwarding, you can edit .kitchen.yml file.
    - to shutdown the virtual Ubuntu, run `sudo poweroff`

    For Spark (make sure hadoop is up and running):
    - `cd ~`
    - To run Spark interactively in a Python interpreter: `pyspark --master local[2]`, the --master option specifies the master URL for a distributed cluster, or local to run locally with one thread, or local[N] to run locally with N threads. Then, you can enter the following code example line by line:
    ```
    text_file = sc.textFile("hdfs://localhost:54310/data/input/imagine.txt")
    counts = text_file.flatMap(lambda line: line.split(" ")).map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b)
    counts.saveAsTextFile("hdfs://localhost:54310/data/output/count")
    ```
    - To run a Spark program directly (which print out the word count result to the console): `spark-submit $SPARK_INSTALL/examples/src/main/python/wordcount.py hdfs://localhost:54310/data/input/imagine.txt`. There are tons of Spark examples at `$SPARK_INSTALL/examples/src/main/python/`, which can be viewed directly at: https://github.com/apache/spark/tree/master/examples/src/main/python

    For HBase (make sure hadoop is up and running):
    - `start-hbase.sh` to start hbase, use `jps` to check: Hmaster, HregionServer, HquorumPeer, verify hbase HDFS directory has been created: `hadoop fs -ls /tmp/hbase-bduser`
    - `hbase shell` to start hbase shell
    - HBase WebUI: http://localhost:16010/master-status

    For Hive (make sure hadoop is up and running):
    - `cd $HIVE_HOME`
    - then, do the following (only once)
    ```
    hdfs dfs -mkdir /tmp
    hadoop fs -chmod g+w /tmp
    hadoop fs -mkdir -p /user/hive/warehouse
    hadoop fs -chmod g+w /user/hive/warehouse
    ```
    - `./bin/schematool -initSchema -dbType derby` to initialize Hive metadata store Derby (only once)
    - `hive` to start hive shell. Try `show tables;` to confirm that hive is running properly.

7. if you want to wipe out everything and start with a clean slate (in case something messed up), you can simply run `kitchen destroy` and then `kitchen converge` - Note: everything on the old virtual Ubuntu is deleted.

### Cookbook Structure
You can use `tree` to generate the tree below.

```
.
├── .kitchen.yml
├── Berksfile
├── Berksfile.lock
├── LICENSE
├── README.md
├── attributes
├── chefignore
├── files
│   ├── config
│   ├── data
│   └── programs
├── metadata.rb
├── recipes
├── templates
└── test
```

- metadata.rb: this file specifies meta data for the cookbook, such as name, author, external cookbook dependencies, etc. The cookbook dependencies are also specified in this file.
- Berksfile: this files specifies the source of external cookbooks (https://supermarket.chef.io), and any external cookbooks
- .kitchen.yml: specifies OS (ubuntu 14.04), port forwarding, and run-list (format: name_of_cookbook::name_of_recipe)
- recipes: all configuration commands are stored in this folder
- files: all files we need to copy to the instance are stored here
- attributes: all attributes we need (I am not using any in this example)
- templates: all templates files (.erb files)

### Install systems on Ubuntu 14.04 Command List

#### Hadoop

If you want to manually configure hadoop, you can copy and paste the following commands:

```
sudo apt-get --assume-yes update
sudo apt-get --assume-yes install default-jdk
java -version
sudo addgroup hadoop
sudo adduser --ingroup hadoop bduser
sudo adduser bduser sudo
sudo apt-get install ssh
which ssh
which sshd
su bduser
ssh-keygen -t rsa -P ""
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys (authrized_keys is a file)
ssh localhost
cd ~
wget http://mirrors.sonic.net/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
tar xvzf hadoop-2.6.0.tar.gz
cd hadoop-2.6.0/
sudo mkdir /usr/local/hadoop
sudo mv * /usr/local/hadoop
sudo chown -R bduser:hadoop /usr/local/hadoop
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
sudo chown bduser:hadoop /app/hadoop/tmp
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

make sure to use bduser: Format the New Hadoop Filesystem

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

You can locally test the python mapper and reducer as follows:

`echo "foo foo bar labs foo bar" | /home/bduser/wc_mapper.py`

```
foo	    1
foo	    1
bar	    1
labs	1
foo	    1
bar	    1
```

`echo "foo foo bar labs foo bar" | /home/bduser/wc_mapper.py | sort -k1,1 | /home/bduser/wc_reducer.py`

```
bar	    2
foo	    3
labs	1
```

`sort`: http://www.theunixschool.com/2012/08/linux-sort-command-examples.html

example: `sort -t"," -k1,1 file` The format of '-k' is : '-km,n' where m is the starting key and n is the ending key. In other words, sort can be used to sort on a range of fields just like how the group by in sql does. In our case, since the sorting is on the 1st field alone, we specify '1,1'. Note: For a file which has fields delimited by a space or a tab, there is no need to specify the "-t" option since the white space is the delimiter by default in sort.

#### Spark

If you want to manually configure spark, you can copy and paste the following commands (make sure hadoop 2.6.0 has been installed and configured):

### Other useful tips

- To copy files from Ubuntu virtualbox: go to settings, add a shared folder, login to ubuntu, go to /media/your_shared_folder (you may need to add user `sudo adduser bduser vboxsf` and then reboot `sudo reboot`)
- If you are starting a new cookbook, you can use `berks cookbook your_cookbook_name` to initialize the folder structure (no need to do this for this cookbook - I have done it for you). Refer to the following tutorial is necessary: use external cookbook: http://docs.aws.amazon.com/opsworks/latest/userguide/cookbooks-101-opsworks-berkshelf.html#cookbooks-101-opsworks-berkshelf-vagrant
- You can add external cookbook in Berksfile as `cookbook 'java'`, you can go to https://supermarket.chef.io to search for a cookbook and find the related berkshelf information there.

### References

- http://www.terpconnect.umd.edu/~kpzhang/ (special thanks to my friend Kunpeng for the course materials)
- http://www.bogotobogo.com/Hadoop/BigData_hadoop_Install_on_ubuntu_single_node_cluster.php
- http://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/
- https://www.linkedin.com/pulse/getting-started-apache-spark-ubuntu-1404-myles-harrison
- https://www.digitalocean.com/community/tutorial_series/getting-started-managing-your-infrastructure-using-chef
- https://www.linkedin.com/pulse/installing-hbase-112-over-hadoop-271in-modeon-ubuntu-1404-sharma
- http://anggao.js.org/install-hive-on-ubuntu-1404-and-hadoop-260.html
- https://mongodblog.wordpress.com/2016/02/27/apache-hive-2-0-0-installation-on-ubuntu-linux-14-04-lts/
- http://www.javamakeuse.com/2016/02/apache-hive-installation-in-ubuntu-hive.html
