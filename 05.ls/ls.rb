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

def main
  if @option.has?(:long)
    generate_detailed_data
    generate_time_stamp
    indent_detailed_data
    indent_time_stamp
    output_long_data
  else
    indent_short_data
    output_short_data
  end
end

def generate_detailed_data
  @blocks = @files.map { |file| File.stat(file).blocks }
  @nlinks = @files.map { |file| File.stat(file).nlink.to_s }
  @file_mode = @files.map { |file| format('%06o', File.stat(file).mode) }
  @permissions = @file_mode.map { |file| convert_file_mode(file) }
  @user_names = @files.map { |file| Etc.getpwuid(File.stat(file).uid).name }
  @group_names = @files.map { |file| Etc.getgrgid(File.stat(file).gid).name }
  @sizes = @files.map { |file| File.stat(file).size.to_s }
end

def generate_time_stamp
  @months = @files.map { |file| File.stat(file).ctime.strftime('%m').to_i.to_s }
  @dates = @files.map { |file| File.stat(file).ctime.strftime('%d').to_i.to_s }
  @times = @files.map { |file| File.stat(file).ctime.strftime('%H:%M').to_s }
end

@file_types = {
  '01': 'p',
  '02': 'c',
  '04': 'd',
  '06': 'b',
  '10': '-',
  '12': 'l',
  '14': 's'
}
@file_permissions = {
  '0': '---',
  '1': '--x',
  '2': '-w-',
  '3': '-wx',
  '4': 'r--',
  '5': 'r-x',
  '6': 'rw-',
  '7': 'rwx'
}

def convert_file_mode(mode)
  file_type = @file_types[mode[0..1].to_sym]
  file_permission_owner = @file_permissions[mode[3].to_sym]
  file_permission_group = @file_permissions[mode[4].to_sym]
  file_permission_others = @file_permissions[mode[5].to_sym]
  file_type + file_permission_owner + file_permission_group + file_permission_others
end

def calculate_max_size(array)
  array.map(&:size).max
end

def indent_detailed_data
  permissions_max_size = calculate_max_size(@permissions)
  nlinks_max_size = calculate_max_size(@nlinks)
  user_names_max_size = calculate_max_size(@user_names)
  group_names_max_size = calculate_max_size(@group_names)
  sizez_max_size = calculate_max_size(@sizes)
  @permissions.map! { |permission| permission.ljust(permissions_max_size + 1) }
  @nlinks.map! { |nlink| nlink.rjust(nlinks_max_size + 1) }
  @user_names.map! { |user_name| "\s#{user_name.ljust(user_names_max_size + 2)}" }
  @group_names.map! { |group_name| group_name.ljust(group_names_max_size) }
  @sizes.map! { |size| size.rjust(sizez_max_size + 2) }
end

def indent_time_stamp
  @months.map! { |month| "\s#{month.rjust(2)}" }
  @dates.map! { |date| date.rjust(3) }
  @times.map! { |time| "#{time.rjust(6)}\s" }
end

def output_long_data
  file_long = [@permissions, @nlinks, @user_names, @group_names, @sizes, @months, @dates, @times, @files]
  puts "total\s#{@blocks.sum}"
  puts(file_long.transpose.map(&:join))
end

def indent_short_data
  @file_short = []
  files_with_indent = @files.map do |file|
    file.ljust(calculate_max_size(@files) + 5)
  end
  files_with_indent.each_slice((@files.size - 1) / 3 + 1) do |file|
    @file_short << file.fill(nil, (@files.size - 1) / 3 + 1, 0)
  end
end

def output_short_data
  puts(@file_short.transpose.map(&:join))
end

main
