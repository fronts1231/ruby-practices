# frozen_string_literal: true

numbers = []
a = 0
while a < 100
  a += 1
  numbers.push(a)
end

numbers.each do |x|
  if (x % 5).zero? && (x % 3).zero?
    puts 'fizzbuzz'
  elsif (x % 5).zero?
    puts 'buzz'
  elsif (x % 3).zero?
    puts 'fizz'
  else
    puts x
  end
end
