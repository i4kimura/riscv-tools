#
# Cookbook Name:: riscv-tools
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "sed apt-source" do
  command "sed -i -e 's%http://archive.ubuntu.com/ubuntu%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive%g' /etc/apt/sources.list"
end.run_action(:run)

execute "update package index" do
  command "apt-get update"
  ignore_failure true
  action :nothing
end.run_action(:run)

log "done update"

packages = %w{autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf}
packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

git "#{Chef::Config['file_cache_path']}/riscv-tools" do
  repository "https://github.com/riscv/riscv-tools.git"
  revision "master"
  enable_submodules true
  action :sync
end

bash "Set Environment of RISCV-tools" do
  code "sed -i 's/JOBS=16/JOBS=1/' #{Chef::Config['file_cache_path']}/riscv-tools/build.common"
  action :run
end

ENV['TOP']   = "/home/vagrant/"
ENV['RISCV'] = "/home/vagrant/riscv"
ENV['PATH']  = "/home/vagrant/riscv/bin:#{ENV["PATH"]}"

execute "Build RISCV-tools" do
  cwd "#{Chef::Config['file_cache_path']}/vagrant/riscv-tools/"
  command "./build.sh"
  action :run
end

