# frozen_string_literal: true

require 'optparse'
require 'etc'

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

@option = Option.new
@files = Dir.entries(Dir.pwd)
@files.sort!

unless @option.has?(:all)
  @files = @files.filter do |file|
    file !~ /^\./
  end
end

if @option.has?(:reverse)
  @files.reverse!
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

def long_description
  file_new = []
  @files.each do |file|
    stat = File.stat(file)
    @block = 0
    @block += stat.blocks
    file_new2 = []
      file_new2 << file_mode(file)
      file_new2 << stat.nlink.to_s.rjust(3)
      file_new2 << "\s" + Etc.getpwuid(stat.uid).name
      file_new2 << "\s" * 2 + Etc.getgrgid(stat.gid).name
      file_new2 << stat.size.to_s.rjust(6)
      file_new2 << stat.ctime.strftime("%m").to_i.to_s.rjust(3)
      file_new2 << stat.ctime.strftime("%d").to_i.to_s.rjust(3)
      file_new2 << stat.ctime.strftime("%H:%M\s").rjust(7)
      file_new2 << file
    file_new << file_new2.join
  end
  puts 'total' + "\s" + @block.to_s
  puts file_new
end

size = @files.map do |file|
  file.size
end
@max_size = size.max

def short_description
  file_short = []
  files_with_indent = @files.map do |file|
    file.ljust(@max_size + 5)
  end
  files_with_indent.each_slice((@files.size - 1) / 3 + 1) do |file|
    file.fill(nil, (@files.size - 1) / 3 + 1, 0)
    file_short << file
  end
  file_short_transposed = file_short.transpose
  file_short_transposed.map! do |file|
    file.join
  end
  puts file_short_transposed
end

if @option.has?(:long)
  long_description
else
  short_description
end
