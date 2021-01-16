# frozen_string_literal: true

require 'optparse'

class Option
  def initialize
    @options = {}
    OptionParser.new do |option|
      option.on('-a') { |v| @options[:all] = v }
      option.on('-r') { |v| @options[:reverse] = v }
      option.on('-l') { |v| @options[:long] = v }
      option.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end

  # def get(name)
  #   @options[name]
  # end

  # def get_extras
  #   ARGV
  # end
end

option = Option.new
files = Dir.entries(Dir.pwd)
files.sort!

unless option.has?(:all)
  files = files.filter do |file|
    file !~ /^\./
  end
end

if option.has?(:reverse)
  files.reverse!
end

def file_mode(file_name)
  file_mode_output = sprintf("%06o", File.stat(file_name).mode)
    file_types = {'01': 'p', '02': 'c', '04': 'd', '06': 'b', '10': '-', '12': 'l', '14': 's'}
    file_permissions = {'0': '---', '1': '--x', '2': '-w-', '3': '-wx', '4': 'r--', '5': 'r-x', '6': 'rw-', '7': 'rwx'}
    file_type = file_types[file_mode_output[0..1].to_sym]
    file_pemission_owner = file_permissions[file_mode_output[3].to_sym]
    file_pemission_group = file_permissions[file_mode_output[4].to_sym]
    file_pemission_others = file_permissions[file_mode_output[5].to_sym]
  file_type + file_pemission_owner + file_pemission_group + file_pemission_others
end

file_new = []
files.each do |file|
  stat = File.stat(file)
  file_new2 = []
  if option.has?(:long)
  file_new2 << file_mode(file)
  file_new2 << stat.nlink.to_s.rjust(3)
  file_new2 << stat.uid.to_s.rjust(4)
  file_new2 << stat.gid.to_s.rjust(3)
  file_new2 << stat.size.to_s.rjust(6)
  file_new2 << stat.ctime.strftime("%m").to_i.to_s.rjust(3)
  file_new2 << stat.ctime.strftime("%d").to_i.to_s.rjust(3)
  file_new2 << stat.ctime.strftime("%H:%M\s").rjust(7)
  end
  file_new2 << file
file_new << file_new2.join
end

puts file_new
