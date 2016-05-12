execute "download spark 1.6.0" do
    user "root"
    cwd "/home/bduser"
    command "wget http://apache.cs.utah.edu/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz"
end

execute "extract spark 1.6.0" do
    user "root"
    cwd "/home/bduser"
    command "tar xvzf spark-1.6.0-bin-hadoop2.6.tgz"
end

directory '/home/bduser/programs/spark' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

cookbook_file '/home/bduser/programs/spark/word_filter.py' do
  source '/programs/spark/word_filter.py'
  owner 'bduser'
  group 'bigdata'
  mode '0755'
  action :create
end
