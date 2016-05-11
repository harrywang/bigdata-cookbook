cookbook_file '/home/hduser/imagine.txt' do
  source '/data/imagine.txt'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end

cookbook_file '/home/hduser/wc_mapper.py' do
  source '/programs/wc_mapper.py'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end

cookbook_file '/home/hduser/wc_reducer.py' do
  source '/programs/wc_reducer.py'
  owner 'hduser'
  group 'hadoop'
  mode '0755'
  action :create
end
