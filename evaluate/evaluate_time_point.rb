require "csv"

@dir_name = ARGV[0] 

def eval_time_point
  this_year = CSV.table("datas/#{@dir_name}/this_year.csv", encoding: "UTF-8")
  result = {}
  this_year.each do |data|
    result.store(data[:horsename],[])
  end
  this_year.each do |data|
    result[data[:horsename]].push(data[:timepoint])
  end
  
  csv_data = []
  result.each do |res|
    horse_name = res[0]
    t = res[1].map{|x|x.to_f}
    num = t.size
    num = 5 if t.size > 5
    time_point_ave = t.take(5).sum / num
    csv_data.push([horse_name, time_point_ave.round(2)])
  end
  sorted = csv_data.sort_by{|x| x[1]*-1 }
  sorted = round_five(sorted)
  sorted.unshift(["horseName","timepoint","round"])
  write(sorted, "evaluated_timepoint")
end

def round_five(result)
  time_points = []
  result.each do |res|
    time_points.push res[1].to_f
  end
  min = time_points.min - 10
  time_points = time_points.map{|x|(x-min)}
  max = time_points.max

  div_num = max.to_f / 5

  five_rounds = time_points.map{|x|(x / div_num).round(2)}
  
  result.each_with_index do |res, i|
    res.push(five_rounds[i])
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



eval_time_point()