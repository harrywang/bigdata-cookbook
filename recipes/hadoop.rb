# Install Oracle Java 7 using java cookbook. Other Java may not work.
# sudo add-apt-repository ppa:webupd8team/java
# sudo apt-get update
# sudo apt-get install oracle-java7-installer
include_recipe 'java'

# apt-get update downloads the package lists from the repositories
# and "updates" them to get information on the newest versions of packages and their dependencies.
# sudo apt-get update
apt_update "update apt sources" do
   action :update
end

# optional - I use vim to edit files on server
apt_package 'vim' do
  action :install
end

# ssh: used to connect to remote machines - the client.
# sshd: the daemon on the server that allows clients to connect to the server.
# The ssh is pre-enabled on Linux, but we need to install ssh to start sshd daemon.
apt_package 'ssh' do
  action :install
end

# Add a dedicated big data group
group 'bigdata' do
  action :create
end

# Add a dedicated big data user and add the user to the group above
# use mkpasswd -m sha-512 to make a hash
# the password is 'test'
user 'bduser' do
  comment 'big data user'
  gid 'bigdata'
  password '$6$kiya1Zs6H2GJxdY$fgFnzKMYs/KN2rufpMio9asn4vtBuPRh5rYTspW.FJjzseQMk/3CvI5ipjUPODteS6tbKdQ9cwl032VO9f5Fb0'
end

# Add user to the sudoer list so that the user can use sudo direclty on the server if needed
execute "add bduser to sudoer list" do
    user "root"
    command "adduser bduser sudo"
end

# Create a directory for ssh certificate
directory '/home/bduser/.ssh/' do
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  recursive true
  action :create
end

# generate a key without password
execute "generate ssh keys for bduser" do
  user "bduser"
  group 'bigdata'
  creates "/home/bduser/.ssh/id_rsa.pub"
  command "ssh-keygen -t rsa -q -f /home/bduser/.ssh/id_rsa -P \"\""
end

# Add the newly created key to the list of authorized keys
# so that Hadoop can use ssh without prompting for a password
execute "add key to authorized keys for password-less ssh" do
  user "bduser"
  group 'bigdata'
  command "cat /home/bduser/.ssh/id_rsa.pub >> /home/bduser/.ssh/authorized_keys"
end

execute "change key permission" do
  user "root"
  command "chown bduser:bigdata /home/bduser/.ssh/authorized_keys"
end

# create hadoop home directory
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
    command "tar -xzf hadoop-2.6.0.tar.gz"
end

execute "move hadoop 2.6.0" do
    user "root"
    cwd "/home/bduser/hadoop-2.6.0"
    command "mv * /usr/local/hadoop"
end

execute "update java alternatives" do
    command "update-alternatives --config java"
end

# configrure the environment variables
cookbook_file '/home/bduser/.bashrc' do
  source '/config/.bashrc'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

bash 'source' do
  user 'bduser'
  group 'bigdata'
  cwd '/home/bduser/'
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

execute "change hadoop streaming jar permission" do
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
