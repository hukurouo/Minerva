require "csv"

# 定数
@dir_name = ARGV[0] 

def evaluate_result()
  dir_name = @dir_name
  this_year = CSV.table("datas/#{dir_name}/this_year.csv", encoding: "UTF-8")
  result_arrange = CSV.table("datas/#{dir_name}/result_arrange.csv", encoding: "UTF-8")

  result_arrange_map = {}
  result_arrange.each do |res|
    value = {
      toppoint1: res[:toppoint1], 
      toppoint2: res[:toppoint2], 
      toppoint3: res[:toppoint3], 
      widepoint1: res[:widepoint1],
      widepoint2: res[:widepoint2],
      widepoint3: res[:widepoint3],
    }
    result_arrange_map.store(res[:racename], value)
  end

  horse_names = this_year[:horsename].uniq
  horse_name_map = {}
  horse_names.each do |name|
    horse_name_map.store(name, {top:[], wide:[]})
  end
  this_year.each do |data|
    name = data[:horsename]
    race = race_name_strip(data[:racename])
    #next if race.include?("万下")
    #next if race.include?("OP")
    rank = data[:rank]
    top_point = 0
    wide_point = 0
    if rank == 1
      top_point = result_arrange_map.dig(race,:toppoint1)
      wide_point = result_arrange_map.dig(race,:widepoint1)
    elsif rank == 2 || rank == 3
      top_point = result_arrange_map.dig(race,:toppoint2)
      wide_point = result_arrange_map.dig(race,:widepoint2)
    else
      top_point = result_arrange_map.dig(race,:toppoint3)
      wide_point = result_arrange_map.dig(race,:widepoint3)
      top_point *= 0.3 if top_point
      wide_point *= 0.3 if wide_point
    end
    horse_name_map[name][:top].push top_point
    horse_name_map[name][:wide].push wide_point
  end
  CSV.open("kakunin.csv", "w") do |csv| 
    horse_name_map.each do |data|
      csv << data
    end
  end
  result_evaluated = []
  horse_name_map.each do |data|
    name = data[0]
    div_t = data[1][:top].compact.length
    div_w = data[1][:wide].compact.length
    div_t = 1 if div_t == 0
    div_w = 1 if div_w == 0
    top = 100 * data[1][:top].compact.sum / div_t
    wide = 100 * data[1][:wide].compact.sum / div_w
    result_evaluated.push([name,top.round(2),wide.round(2)])
  end

  sorted = result_evaluated.sort_by{|x| x[2]*-1 }
  rounded = round_five(sorted)
  #sorted2 = result_evaluated.sort_by{|x| x[1]*-1 }
  rounded.unshift(["horseName","topPoint","WidePoint","roundTop","roundWide"])
  #sorted2.unshift(["horseName","topPoint","WidePoint"])
  #write(sorted, "result_evaluated_sort_by_Wide")
  #write(sorted2, "result_evaluated_sort_by_Top")
  write(rounded, "evaluated_result")
  
end

def race_name_strip(race_name)
  if race_name.include? "("
    race_name = race_name.split("(")[0]
  else
    race_name
  end
end

def write(result_evaluated, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    result_evaluated.each do |data|
      csv << data
    end
  end
end

def round_five(result)
  top_points = []
  wide_points = []
  result.each do |res|
    top_points.push res[1]
    wide_points.push res[2]
  end
  max_top_point = top_points.max || 0
  max_wide_point = wide_points.max || 0

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

evaluate_result()