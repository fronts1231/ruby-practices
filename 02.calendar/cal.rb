# frozen_string_literal: true

require 'optparse'
require 'date'

options = ARGV.getopts('y:', 'm:')

year = if options['y'].nil?
         Date.today.year.to_i
       else
         options['y'].to_i
       end

month = if options['m'].nil?
          Date.today.mon.to_i
        else
          options['m'].to_i
        end

puts "#{month}月 #{year}".rjust(13)
puts '日 月 火 水 木 金 土'

first = Date.new(year, month, 1)
final = Date.new(year, month, -1)

(first..final).each do |x|
  date = x.mday.to_s.rjust(2)
  spaces = "\s" * x.cwday * 3
  if x == first && x.cwday == 6
    print "#{spaces}#{date}\s\n"
  elsif x == first && x.cwday < 7
    print "#{spaces}#{date}\s"
  elsif x == final || x.cwday == 6
    print "#{date}\s\n"
  else
    print "#{date}\s"
  end
end
