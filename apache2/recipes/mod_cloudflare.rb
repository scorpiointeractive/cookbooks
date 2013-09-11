#
# Cookbook Name:: apache2
# Recipe:: mod_cloudflare
#

case node[:platform]
when "debian","ubuntu"
  package "libapache2-mod-rpaf"

when "redhat","centos","oracle","amazon","arch"
  cloudflare_url = "https://raw.github.com/cloudflare/mod_cloudflare/master/mod_cloudflare.c"
  src_filepath  = "/tmp/mod_cloudflare.c"
  src_dir = File.dirname(src_filepath)
  basename = File.basename(src_filepath)
  
  log "  CloudFlare Url = #{cloudflare_url}"
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

  #remote_file cloudflare_url do
  #  source cloudflare_url
  #  path src_filepath
  #  backup false
  # end
  
  bash "compile mod_cloudflare" do
    cwd ::File.dirname(src_filepath)
    code <<-EOH
      wget #{cloudflare_url} && 
      apxs -i -c -n mod_cloudflare.so mod_cloudflare.c
    EOH
  end
end

apache_module "cloudflare" do
  filename "mod_cloudflare.so"
  conf false
end
