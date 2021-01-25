# frozen_string_literal: true

require 'optparse'

class Option
  def initialize
    @options = {}
    OptionParser.new do |option|
      option.on('-l') { |v| @options[:lines] = v }
      option.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end
end

option = Option.new

files = []
ARGV.each { |file| files << file }
files.map! { |file| File.absolute_path(file) }

inputs = if ARGV.size >= 1
           files.map! { |file| File.readlines(file) }
         else
           [$stdin.readlines]
         end

lines = inputs.map(&:size)
items = inputs.map { |input| input.join.gsub(/\s{2,}/, "\s").count("/\s\n/") }
bytes = inputs.map { |input| input.join.size }

if ARGV.size >= 2
  lines << lines.sum
  items << items.sum
  bytes << bytes.sum
  names = ARGV.push('total')
else
  names = ARGV.fill(nil, inputs.size, 0)
end

max_size = [lines.sum.to_s, items.sum.to_s, bytes.sum.to_s].map(&:size).max

contents = [
  lines.push.map { |line| "#{line.to_s.rjust(max_size + 5)}\s" },
  items.push.map { |item| "#{item.to_s.rjust(max_size + 4)}\s" },
  bytes.push.map { |byte| "#{byte.to_s.rjust(max_size + 4)}\s" },
  names
]

contents = [contents.first, contents.last] if option.has?(:lines)

puts contents.transpose.map(&:join)
