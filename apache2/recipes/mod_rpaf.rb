#
# Cookbook Name:: apache2
# Recipe:: mod_rpaf
#

case node[:platform]
when "debian","ubuntu"
  package "libapache2-mod-rpaf"

when "redhat","centos","oracle","amazon","arch"
  rpaf_url = "http://stderr.net/apache/rpaf/download/mod_rpaf-0.6.tar.gz"
  src_filepath  = "/tmp/mod_rpaf-0.6.tar.gz"
  src_dir = File.dirname(src_filepath)
  basename = File.basename(src_filepath)
  
  log "  RPAF Url = #{rpaf_url}"
  log "  Source Path = #{src_filepath}"
  log "  Source Directory = #{src_dir}"
  log "  Filename = #{basename}"
  
  packages = value_for_platform(
    ["centos","redhat","fedora","amazon","scientific","arch"] => {'default' => ['httpd-devel']},
    ["ubuntu","debian"] => {"default" => ['apache2-dev']},
    "default" => []
  )
 
  packages.each do |devpkg|
    package devpkg
  end

  remote_file rpaf_url do
    source rpaf_url
    path src_filepath
    backup false
  end

  bash "compile mod_rpaf" do
    cwd ::File.dirname(src_filepath)
    code <<-EOH
      tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)} &&
      cd mod_rpaf-0.6 &&
      apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
    EOH
  end
end
 
apache_module "rpaf" do 
  filename "mod_rpaf-2.0.so"
  conf true
end
