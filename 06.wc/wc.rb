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

@option = Option.new

files = []
ARGV.each { |file| files << file }
files.map! { |file| File.absolute_path(file) }

if ARGV.size >= 2
  @inputs = files.map! { |file| File.readlines(file) }
  names = ARGV.push('total')
else
  input = $stdin.readlines
  @inputs = [input]
  names = ARGV.fill(nil, @inputs.size + 1, 0)
end

lines = @inputs.map { |input| input.size }
items = @inputs.map { |input| input.join.gsub(/\s{2,}/,"\s").count("/\s/\n/") }
bytes = @inputs.map { |input| input.join.size }

max_size = [lines.sum.to_s, items.sum.to_s, bytes.sum.to_s].map(&:size).max

contents = [
  lines.push(lines.sum).map { |line| line.to_s.rjust(max_size + 3) + "\s" },
  items.push(items.sum).map { |item| item.to_s.rjust(max_size + 4) },
  bytes.push(bytes.sum).map { |byte| byte.to_s.rjust(max_size + 4) + "\s" },
  names
]

if @option.has?(:lines)
  contents = [contents.first, contents.last]
end

contents_transposed = contents.transpose.map(&:join)


if ARGV.size >= 3
  puts contents_transposed
else
  puts contents_transposed.pop(1)
end
