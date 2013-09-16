#
# Cookbook Name:: apache2
# Recipe:: mod_rpaf
#

case node[:platform]
when "debian","ubuntu"
  package "libapache2-mod-rpaf"

when "redhat","centos","oracle","amazon","arch"
  
  packages = value_for_platform(
    ["centos","redhat","fedora","amazon","scientific","arch"] => {'default' => ['httpd-devel']},
    ["ubuntu","debian"] => {"default" => ['apache2-dev']},
    "default" => []
  )
 
  packages.each do |devpkg|
    package devpkg
  end

  #remote_file rpaf_url do
  #  source rpaf_url
  #  path src_filepath
  #  backup false
  #end

  prefix			= node[:scorpio_defaults][:mod_rpaf_backup_prefix]
  storage_provider 		= node[:scorpio_defaults][:storage_provider]
  storage_container 		= node[:scorpio_defaults][:storage_container]
  dst_filepath  	 	= "/tmp/mod_rpaf-0.6.tar.gz"
  dst_dir 			= File.dirname(dst_filepath)
  basename 			= File.basename(dst_filepath)
  storage_accnt_id 		= node[:scorpio_defaults][:storage_accnt_id]
  storage_accnt_secret 		= node[:scorpio_defaults][:storage_accnt_secret]
  
  command_to_execute = "/opt/rightscale/sandbox/bin/ros_util get" +
    " --cloud #{storage_provider} --container #{storage_container}" +
    " --dest #{dst_filepath}" +
    " --source #{prefix} --latest"
    
  options = {}

  environment_variables = {
    'STORAGE_ACCOUNT_ID' => storage_accnt_id,
    'STORAGE_ACCOUNT_SECRET' => storage_accnt_secret
  }.merge(options)

  execute "Download mod_rpaf from Remote Object Store" do
    command command_to_execute
    creates dst_filepath
    environment environment_variables
  end

  bash "compile mod_rpaf" do
    cwd dst_dir
    code <<-EOH
      tar zxf #{basename} &&
      cd mod_rpaf-0.6 && 
      apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
    EOH
  end
end
 
apache_module "rpaf" do 
  filename "mod_rpaf-2.0.so"
  conf true
end
