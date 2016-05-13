directory '/usr/local/spark' do
    owner 'bduser'
    group 'bigdata'
    recursive true
    action :create
end

execute "download spark 1.6.0" do
    user "root"
    cwd "/home/bduser"
    command "wget http://apache.cs.utah.edu/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz"
end

execute "extract spark 1.6.0" do
    user "root"
    cwd "/home/bduser"
    command "tar -xzf spark-1.6.0-bin-hadoop2.6.tgz"
end

execute "move spark 1.6.0" do
    user "root"
    cwd "/home/bduser/spark-1.6.0-bin-hadoop2.6"
    command "mv * /usr/local/spark"
end
