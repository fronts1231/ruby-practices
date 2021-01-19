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
  fill_after_strike(shots)
end

def fill_after_strike(shots)
  shots.each_with_index do |shot, i|
    shots.insert(i + 1, 0) if shot == 10 && i.even?
  end
  slice_by_frame(shots)
end

def slice_by_frame(shots)
  frames = []
  shots.each_slice(2) do |shot|
    frames << shot
  end
  @shots = shots
  calculate_score(frames)
end

def calculate_score(frames)
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
