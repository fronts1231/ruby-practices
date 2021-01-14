def bowling(score)
  # score = ARGV[0].to_s
  scores = score.chars
  shots = []
  scores.each do |s|
    if s == 'X'
      shots << 10
      shots << 0
    else
      shots << s.to_i
    end
  end

  frames = []
  shots.each_slice(2) do |s|
    frames << s
  end

  point = 0
  frames.each_with_index do |f, i|
    number = i * 2
    if f[0] == 10
      point += shots[number..(number + 3)].sum
    elsif f.sum == 10 && i != 9
      point += shots[number..(number + 2)].sum
    else
      point += f.sum
    end
  end
  p frames
  p point
end

# bowling(ARGV[0])
