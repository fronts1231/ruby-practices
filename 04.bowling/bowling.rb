# frozen_string_literal: true

def bowling(result)
  score = result.to_s
  scores = score.chars
  shots = []
  scores.each do |s|
    shots << if s != 'X'
               s.to_i
             else
               10
             end
  end
  bowling1(shots)
end

def bowling1(shots)
  shots.each_with_index do |shot, i|
    shots.insert(i + 1, 0) if shot == 10 && i.even?
  end
  bowling2(shots)
end

def bowling2(shots)
  frames = []
  shots.each_slice(2) do |shot|
    frames << shot
  end
  @shots = shots
  bowling3(frames)
end

def bowling3(frames)
  point = 0
  frames.each_with_index do |frame, i|
    number = i * 2
    point += if frame.sum != 10 || i >= 9
               @shots[number..(number + 1)].sum
             elsif frame[0] == 10 && frames[i + 1] == [10, 0]
               @shots[number..(number + 4)].sum
             elsif frame[0] == 10
               @shots[number..(number + 3)].sum
             else
               @shots[number..(number + 2)].sum
             end
  end
  p point
end

bowling(ARGV[0])
