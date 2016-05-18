directory '/usr/local/hbase' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

execute "download hbase 1.1.5" do
    user "root"
    cwd "/home/bduser"
    command "wget http://apache.claz.org/hbase/stable/hbase-1.1.5-bin.tar.gz"
end

execute "extract hbase" do
    user "root"
    cwd "/home/bduser"
    command "tar -xzf hbase-1.1.5-bin.tar.gz"
end

execute "move hbase" do
    user "root"
    cwd "/home/bduser/hbase-1.1.5"
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
