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
end

@option = Option.new
@files = Dir.entries(Dir.pwd).sort!

unless @option.has?(:all)
  @files = @files.filter do |file|
    file !~ /^\./
  end
end

@files.reverse! if @option.has?(:reverse)

def max_size(array)
  array.map(&:size).max
end

def file_mode(file_name)
  file_mode_output = format('%06o', File.stat(file_name).mode)
  file_types = { '01': 'p', '02': 'c', '04': 'd', '06': 'b', '10': '-', '12': 'l', '14': 's' }
  file_permissions = { '0': '---', '1': '--x', '2': '-w-', '3': '-wx', '4': 'r--', '5': 'r-x', '6': 'rw-', '7': 'rwx' }
  file_type = file_types[file_mode_output[0..1].to_sym]
  file_pemission_owner = file_permissions[file_mode_output[3].to_sym]
  file_pemission_group = file_permissions[file_mode_output[4].to_sym]
  file_pemission_others = file_permissions[file_mode_output[5].to_sym]
  file_type + file_pemission_owner + file_pemission_group + file_pemission_others
end

@blocks = @files.map { |file| File.stat(file).blocks }
permissions = @files.map { |file| file_mode(file) }
nlinks = @files.map { |file| File.stat(file).nlink.to_s }
user_names = @files.map { |file| Etc.getpwuid(File.stat(file).uid).name }
group_names = @files.map { |file| Etc.getgrgid(File.stat(file).gid).name }
sizes = @files.map { |file| File.stat(file).size.to_s }
months = @files.map { |file| File.stat(file).ctime.strftime('%m').to_i.to_s }
dates = @files.map { |file| File.stat(file).ctime.strftime('%d').to_i.to_s }
times = @files.map { |file| File.stat(file).ctime.strftime("%H:%M\s").to_s }

file_long = [
  permissions.map { |permission| permission.ljust(max_size((permissions)) + 1) },
  nlinks.map { |nlink| nlink.rjust(max_size((nlinks)) + 1) },
  user_names.map { |user_name| "\s#{user_name.ljust(max_size((user_names)) + 2)}" },
  group_names.map { |group_name| group_name.ljust(max_size((group_names))) },
  sizes.map { |size| size.rjust(max_size((sizes)) + 2) },
  months.map { |month| "\s#{month.rjust(2)}" },
  dates.map { |date| date.rjust(3) },
  times.map { |time| time.rjust(7) },
  @files
]

file_short = []
files_with_indent = @files.map do |file|
  file.ljust(max_size(@files) + 5)
end
files_with_indent.each_slice((@files.size - 1) / 3 + 1) do |file|
  file_short << file.fill(nil, (@files.size - 1) / 3 + 1, 0)
end

if @option.has?(:long)
  puts "total\s#{@blocks.sum}"
  puts(file_long.transpose.map(&:join))
else
  puts(file_short.transpose.map(&:join))
end
