#
# Cookbook Name:: apache2
# Recipe:: mod_cloudflare
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

  #remote_file cloudflare_url do
  #  source cloudflare_url
  #  path src_filepath
  #  backup false
  # end

  prefix			= node[:scorpio_defaults][:mod_rpaf_backup_prefix]
  storage_provider 		= node[:scorpio_defaults][:storage_provider]
  storage_container 		= node[:scorpio_defaults][:storage_container]
  dst_filepath  	 	= "/tmp/mod_cloudflare.tar.gz"
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
  
  bash "compile mod_cloudflare" do
    cwd dst_dir
    code <<-EOH
      tar zxf #{basename} &&
      apxs -i -c -n mod_cloudflare.so mod_cloudflare.c
    EOH
  end
end

apache_module "cloudflare" do
  filename "mod_cloudflare.so"
  conf false
end
