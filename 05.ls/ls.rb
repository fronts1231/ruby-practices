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

option = Option.new
files = Dir.entries(Dir.pwd).sort!

unless option.has?(:all)
  files = files.filter do |file|
    file !~ /^\./
  end
end

files.reverse! if option.has?(:reverse)

def main_long_data(items)
  stats = items.map { |item| File.stat(item) }
  file_long = Array.new([generate_permission(stats), generate_detailed_data(stats), generate_time_stamps(stats), items])
  puts "total\s#{stats.map(&:blocks).sum}"
  puts file_long.flatten!.each_slice(items.size).to_a.transpose.map(&:join)
end

def main_short_data(items)
  file_short = []
  files_with_indent = items.map do |item|
    item.ljust(calculate_max_size(items) + 5)
  end
  files_with_indent.each_slice((items.size - 1) / 3 + 1) do |item|
    file_short << item.fill(nil, (items.size - 1) / 3 + 1, 0)
  end
  puts file_short.transpose.map(&:join)
end

def generate_permission(stats)
  file_mode = stats.map { |stat| format('%06o', stat.mode) }
  permissions = file_mode.map { |stat| convert_file_mode(stat) }
  permissions_max_size = calculate_max_size(permissions)
  permissions.map! { |permission| permission.ljust(permissions_max_size + 1) }
end

def generate_detailed_data(stats)
  detailed_data = [
    stats.map { |stat| stat.nlink.to_s },
    stats.map { |stat| Etc.getpwuid(stat.uid).name },
    stats.map { |stat| Etc.getgrgid(stat.gid).name },
    stats.map { |stat| stat.size.to_s }
  ]
  arrange_detailed_data(detailed_data)
end

def generate_time_stamps(stats)
  months = stats.map { |stat| stat.ctime.strftime('%m').to_i.to_s }
  months.map! { |month| "\s#{month.rjust(2)}" }
  dates = stats.map { |stat| stat.ctime.strftime('%d').to_i.to_s }
  dates.map! { |date| date.rjust(3) }
  times = stats.map { |stat| stat.ctime.strftime('%H:%M').to_s }
  times.map! { |time| "#{time.rjust(6)}\s" }
  months + dates + times
end

def convert_file_mode(mode)
  file_types = {
    '01': 'p',
    '02': 'c',
    '04': 'd',
    '06': 'b',
    '10': '-',
    '12': 'l',
    '14': 's'
  }
  file_permissions = {
    '0': '---',
    '1': '--x',
    '2': '-w-',
    '3': '-wx',
    '4': 'r--',
    '5': 'r-x',
    '6': 'rw-',
    '7': 'rwx'
  }
  file_types[mode[0..1].to_sym] + file_permissions[mode[3].to_sym] + file_permissions[mode[4].to_sym] + file_permissions[mode[5].to_sym]
end

def arrange_detailed_data(arrays)
  nlinks_indent = calculate_max_size(arrays[0]) + 1
  user_names_indent = calculate_max_size(arrays[1]) + 2
  group_names_indent = calculate_max_size(arrays[2])
  sizes_indent = calculate_max_size(arrays[3]) + 2
  [
    arrays[0].map { |array| array.rjust(nlinks_indent) },
    arrays[1].map { |array| "\s#{array.ljust(user_names_indent)}" },
    arrays[2].map { |array| array.ljust(group_names_indent) },
    arrays[3].map { |array| array.rjust(sizes_indent) }
  ]
end

def calculate_max_size(array)
  array.map(&:size).max
end

if option.has?(:long)
  main_long_data(files)
else
  main_short_data(files)
end
