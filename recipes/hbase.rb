directory '/usr/local/hbase' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

execute "download hbase 1.1.4" do
    user "root"
    cwd "/home/bduser"
    command "wget http://mirrors.koehn.com/apache/hbase/1.1.4/hbase-1.1.4-bin.tar.gz"
end

execute "extract hbase 1.1.4" do
    user "root"
    cwd "/home/bduser"
    command "tar -xzf hbase-1.1.4-bin.tar.gz"
end

execute "move spark 1.6.0" do
    user "root"
    cwd "/home/bduser/hbase-1.1.4"
    command "mv * /usr/local/hbase"
end

cookbook_file '/usr/local/hbase/conf/hbase-site.xml' do
  source '/config/hbase-site.xml'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end

cookbook_file '/usr/local/hbase/conf/hbase-env.sh' do
  source '/config/hbase-env.sh'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end
