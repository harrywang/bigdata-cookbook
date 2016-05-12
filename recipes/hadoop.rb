include_recipe 'java'

apt_update "update apt sources" do
   action :update
end

apt_package 'vim' do
  action :install
end

apt_package 'ssh' do
  action :install
end

group 'bigdata' do
  action :create
end

# use mkpasswd -m sha-512 to make a hash
# the password is 'test'
user 'bduser' do
  comment 'big data user'
  gid 'bigdata'
  password '$6$kiya1Zs6H2GJxdY$fgFnzKMYs/KN2rufpMio9asn4vtBuPRh5rYTspW.FJjzseQMk/3CvI5ipjUPODteS6tbKdQ9cwl032VO9f5Fb0'
end

execute "add bduser to sudoer list" do
    user "root"
    command "adduser bduser sudo"
end

directory '/home/bduser/.ssh/' do
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  recursive true
  action :create
end

execute "generate ssh keys for bduser" do
  user "bduser"
  group 'bigdata'
  creates "/home/bduser/.ssh/id_rsa.pub"
  command "ssh-keygen -t rsa -q -f /home/bduser/.ssh/id_rsa -P \"\""
end

execute "add key to authorized keys for password-less ssh" do
  user "bduser"
  group 'bigdata'
  command "cat /home/bduser/.ssh/id_rsa.pub >> /home/bduser/.ssh/authorized_keys"
end

execute "change key permission" do
  user "root"
  command "chown bduser:bigdata /home/bduser/.ssh/authorized_keys"
end

directory '/usr/local/hadoop' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

execute "download hadoop 2.6.0" do
    user "root"
    cwd "/home/bduser"
    command "wget http://mirrors.sonic.net/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz"
end

execute "extract hadoop 2.6.0" do
    user "root"
    cwd "/home/bduser"
    command "tar xvzf hadoop-2.6.0.tar.gz"
end

execute "move hadoop 2.6.0" do
    user "root"
    cwd "/home/bduser/hadoop-2.6.0"
    command "mv * /usr/local/hadoop"
end

execute "update java alternatives" do
    command "update-alternatives --config java"
end

cookbook_file '/home/bduser/.bashrc' do
  source '/config/.bashrc'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

bash 'source bashrc file' do
  code 'source /home/bduser/.bashrc'
end

execute "readlink java" do
    user "bduser"
    command "readlink -f /usr/bin/javac /usr/lib/jvm/java-7-oracle-amd64/bin/javac"
end

cookbook_file '/usr/local/hadoop/etc/hadoop/hadoop-env.sh' do
  source '/config/hadoop-env.sh'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

directory '/app/hadoop/tmp' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

cookbook_file '/usr/local/hadoop/etc/hadoop/core-site.xml' do
  source '/config/core-site.xml'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

cookbook_file '/usr/local/hadoop/etc/hadoop/mapred-site.xml' do
  source '/config/mapred-site.xml'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

directory '/usr/local/hadoop_store' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

directory '/usr/local/hadoop_store/hdfs/namenode' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

directory '/usr/local/hadoop_store/hdfs/datanode' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

cookbook_file '/usr/local/hadoop/etc/hadoop/hdfs-site.xml' do
  source '/config/hdfs-site.xml'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

execute "hadoop formatting" do
    user "bduser"
    command "/usr/local/hadoop/bin/hadoop namenode -format"
end

execute "download hadoop streaming jar 2.6.0" do
    user "root"
    cwd "/home/bduser"
    command "wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-streaming/2.6.0/hadoop-streaming-2.6.0.jar"
end

execute "chown hadoop streaming jar" do
    user "root"
    command "chown bduser:bigdata /home/bduser/hadoop-streaming-2.6.0.jar"
end

directory '/home/bduser/data' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

directory '/home/bduser/programs/hadoop' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

cookbook_file '/home/bduser/data/imagine.txt' do
  source '/data/imagine.txt'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

cookbook_file '/home/bduser/programs/hadoop/wc_mapper.py' do
  source '/programs/hadoop/wc_mapper.py'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

cookbook_file '/home/bduser/programs/hadoop/wc_reducer.py' do
  source '/programs/hadoop/wc_reducer.py'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end
