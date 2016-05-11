include_recipe 'java'

apt_update "update apt sources" do
   action :update
end

apt_package 'ssh' do
  action :install
end

group 'hadoop' do
  action :create
end

# use mkpasswd -m sha-512 to make a hash
# the password is 'test'
user 'hduser' do
  comment 'hadoop user'
  gid 'hadoop'
  password '$6$kiya1Zs6H2GJxdY$fgFnzKMYs/KN2rufpMio9asn4vtBuPRh5rYTspW.FJjzseQMk/3CvI5ipjUPODteS6tbKdQ9cwl032VO9f5Fb0'
end

execute "add hduser to sudoer list" do
    user "root"
    command "adduser hduser sudo"
end

directory '/home/hduser/.ssh/' do
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  recursive true
  action :create
end

execute "generate ssh keys for hduser" do
  user "hduser"
  group 'hadoop'
  creates "/home/hduser/.ssh/id_rsa.pub"
  command "ssh-keygen -t rsa -q -f /home/hduser/.ssh/id_rsa -P \"\""
end

execute "add key to authorized keys for password-less ssh" do
  user "hduser"
  group 'hadoop'
  command "cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys"
end

execute "change key permission" do
  user "root"
  command "chown hduser:hadoop /home/hduser/.ssh/authorized_keys"
end

directory '/usr/local/hadoop' do
    owner 'hduser'
    group 'hadoop'
    recursive true
    action :create
end

execute "download hadoop 2.6.0" do
    user "root"
    cwd "/home/hduser"
    command "wget http://mirrors.sonic.net/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz"
end

execute "extract hadoop 2.6.0" do
    user "root"
    cwd "/home/hduser"
    command "tar xvzf hadoop-2.6.0.tar.gz"
end

execute "move hadoop 2.6.0" do
    user "root"
    cwd "/home/hduser/hadoop-2.6.0"
    command "mv * /usr/local/hadoop"
end

execute "update java alternatives" do
    command "update-alternatives --config java"
end

cookbook_file '/home/hduser/.bashrc' do
  source '/config/.bashrc'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end

bash 'source bashrc file' do
  code 'source /home/hduser/.bashrc'
end

execute "readlink java" do
    user "hduser"
    command "readlink -f /usr/bin/javac /usr/lib/jvm/java-7-oracle-amd64/bin/javac"
end

cookbook_file '/usr/local/hadoop/etc/hadoop/hadoop-env.sh' do
  source '/config/hadoop-env.sh'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end

directory '/app/hadoop/tmp' do
    owner 'hduser'
    group 'hadoop'
    recursive true
    action :create
end

cookbook_file '/usr/local/hadoop/etc/hadoop/core-site.xml' do
  source '/config/core-site.xml'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end

cookbook_file '/usr/local/hadoop/etc/hadoop/mapred-site.xml' do
  source '/config/mapred-site.xml'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end

directory '/usr/local/hadoop_store' do
    owner 'hduser'
    group 'hadoop'
    recursive true
    action :create
end

directory '/usr/local/hadoop_store/hdfs/namenode' do
    owner 'hduser'
    group 'hadoop'
    recursive true
    action :create
end

directory '/usr/local/hadoop_store/hdfs/datanode' do
    owner 'hduser'
    group 'hadoop'
    recursive true
    action :create
end

cookbook_file '/usr/local/hadoop/etc/hadoop/hdfs-site.xml' do
  source '/config/hdfs-site.xml'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end

execute "hadoop formatting" do
    user "hduser"
    command "/usr/local/hadoop/bin/hadoop namenode -format"
end

execute "download hadoop streaming jar 2.6.0" do
    user "root"
    cwd "/home/hduser"
    command "wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-streaming/2.6.0/hadoop-streaming-2.6.0.jar"
end

execute "chown hadoop streaming jar" do
    user "root"
    command "chown hduser:hadoop /home/hduser/hadoop-streaming-2.6.0.jar"
end
