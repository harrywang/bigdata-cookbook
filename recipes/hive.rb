# Hive Home directory
directory '/usr/local/hive' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

# tmp folder for the io logs
# see https://mongodblog.wordpress.com/2016/03/12/hive-2-0-errors-while-starting/
directory '/usr/local/hive/iotmp' do
    owner 'bduser'
    group 'bigdata'
    mode '0755'
    recursive true
    action :create
end

execute "download hive 2.0.0" do
    user "root"
    cwd "/home/bduser"
    command "wget http://apache.claz.org/hive/hive-2.0.0/apache-hive-2.0.0-bin.tar.gz"
end

execute "extract hive 2.0.0" do
    user "root"
    cwd "/home/bduser"
    command "tar -xzf apache-hive-2.0.0-bin.tar.gz"
end

execute "move hive 2.0.0" do
    user "root"
    cwd "/home/bduser/apache-hive-2.0.0-bin"
    command "mv * /usr/local/hive"
end

cookbook_file '/usr/local/hive/bin/hive-config.sh' do
  source '/config/hive-config.sh'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

cookbook_file '/usr/local/hive/conf/hive-site.xml' do
  source '/config/hive-site.xml'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end
