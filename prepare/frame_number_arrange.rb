require "csv"

header_str = "raceName,arrange1,arrange2,arrange3,topPoint1,widePoint1,topPoint2,widePoint2,topPoint3,widePoint3" 
@result_arrange_data = [header_str.split(",")]

@dir_name = ARGV[0] #"0502victoriamile"
@base_race_name = ARGV[1].encode("UTF-8") #"ヴィクトリアマイル(G1)"

def frame_number_arrange
  data = CSV.table("datas/#{@dir_name}/10years.csv", encoding: "UTF-8")
  top_frame_number = []
  wide_frame_number = []
  data.each do |d|
    if d[:racename] == @base_race_name
      if d[:rank] == 1
        top_frame_number.push d[:framenumber]
        wide_frame_number.push d[:framenumber]
      elsif d[:rank] == 2 || d[:rank] == 3
        wide_frame_number.push d[:framenumber]
      end
    end
  end
  frame_nums = [1,2,3,4,5,6,7,8]
  top_f_size = top_frame_number.size
  wide_f_size = wide_frame_number.size

  csv_data = []
  frame_nums.each do |num|
    top_perc = (top_frame_number.select { |n| n == num }).size.to_f / top_f_size
    wide_perc = (wide_frame_number.select { |n| n == num }).size.to_f / wide_f_size
    csv_data.push([num, top_perc.round(2), wide_perc.round(2)])
  end
  csv_data = round_five(csv_data)
  csv_data.unshift(["frameNumber","topPerc","widePerc","roundTop","roundWide"])
  write(csv_data, "evaluated_frame_number")
end

def round_five(result)
  top_points = []
  wide_points = []
  result.each do |res|
    top_points.push res[1].to_f
    wide_points.push res[2].to_f
  end
  max_top_point = top_points.max
  max_wide_point = wide_points.max

  div_t = max_top_point / 5
  div_w = max_wide_point / 5

  five_round_top_points = top_points.map{|x|(x / div_t).round(2)}
  five_round_wide_points = wide_points.map{|x|(x / div_w).round(2)}
  
  result.each_with_index do |res, i|
    res.push(five_round_top_points[i])
    res.push(five_round_wide_points[i])
  end
  result
end

def write(csv_data, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    csv_data.each do |data|
      csv << data
    end
  end
end

frame_number_arrange()