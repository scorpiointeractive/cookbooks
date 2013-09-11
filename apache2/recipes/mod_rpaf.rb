#
# Cookbook Name:: apache2
# Recipe:: mod_rpaf
#

case node[:platform]
when "debian","ubuntu"
	package "libapache2-mod-rpaf"

when "redhat","centos","oracle","amazon","arch"

end
 
apache_module "rpaf" do 
  conf true
end
