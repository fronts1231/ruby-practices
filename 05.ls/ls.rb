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

# files.each do |file|
#   stat = File.stat(file)
#   print "0%o" % stat.mode.to_s.rjust(8)
#   print stat.nlink.to_s.rjust(2)
#   print stat.uid.to_s.rjust(4)
#   print stat.gid.to_s.rjust(3)
#   print stat.size.to_s.rjust (6)
#   print stat.ctime.strftime("%m").to_i.to_s.rjust(3)
#   print stat.ctime.strftime("%d").to_i.to_s.rjust(3)
#   print stat.ctime.strftime("%H:%M").rjust(6)
#   print "\n"
# end

file_new = []
files.each do |file|
  files.reverse!
  stat = File.stat(file)
  file_new2 = []
  if option.has?(:long)
    file_new2 << "0%o" % stat.mode.to_s.rjust(8)
    file_new2 << stat.nlink.to_s.rjust(2)
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
