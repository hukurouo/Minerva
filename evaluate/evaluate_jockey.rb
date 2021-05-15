require "csv"

# 定数
@dir_name = ARGV[0] 
@race_type_m = ARGV[1].encode("UTF-8")  #"芝1600m"
@race_tyoe_b = ARGV[2].encode("UTF-8")  #"東京"

def evaluate_jockey
  jockey_datas = CSV.table("datas/#{@dir_name}/this_year_card.csv", {:encoding => 'UTF-8', :converters => nil})
  evaluated = []
  jockey_datas.each do |data|
    jockey_name = data[:jockeyname]
    horse_name = data[:horsename]
    eval_hash_m = {}
    eval_hash_b = {}

    top_point_m = 0
    wide_point_m = 0
    top_point_b = 0
    wide_point_b = 0

    top_raterate_m = 0
    top_raterate_b = 0
    wide_raterate_m = 0
    wide_raterate_b = 0

    jockey_result = CSV.table("datas/jockey/csv/#{data[:jockeyid]}.csv", {:encoding => 'UTF-8'})
    jockey_result.each do |res|
      if res[:type] == @race_type_m
        top_point_m = eval_data(res)[0]
        wide_point_m = eval_data(res)[1]
        top_raterate_m = eval_data(res)[2]
        wide_raterate_m = eval_data(res)[3]
        eval_hash_m.store("count",res[:count])
        eval_hash_m.store("winRate", res[:winrate])
        eval_hash_m.store("wideRate", res[:widerate])
        eval_hash_m.store("topRecoveryRate", res[:toprecoveryrate])
        eval_hash_m.store("wideRecoveryRate", res[:widerecoveryrate])
      elsif res[:type] == @race_tyoe_b
        top_point_b = eval_data(res)[0]
        wide_point_b = eval_data(res)[0]
        top_raterate_b = eval_data(res)[2]
        wide_raterate_b = eval_data(res)[3]
        eval_hash_b.store("count",res[:count])
        eval_hash_b.store("winRate", res[:winrate])
        eval_hash_b.store("wideRate", res[:widerate])
        eval_hash_b.store("topRecoveryRate", res[:toprecoveryrate])
        eval_hash_b.store("wideRecoveryRate", res[:widerecoveryrate])
      end
    end
    total_top_point = top_point_m + top_point_b
    total_wide_point = wide_point_m + wide_point_b
    total_top_raterate = top_raterate_m + top_raterate_b
    total_wide_raterate = wide_raterate_m + wide_raterate_b
    evaluated.push([horse_name,jockey_name, total_top_point, total_wide_point, total_top_raterate, total_wide_raterate])
  end
  sorted = evaluated.sort_by{|x| x[5]*-1 }
  sorted = round_five(sorted)
  sorted.unshift(["horseName","jockeyname","topPoint","WidePoint","topRatePoint","wideRatePoint","roundTop","roundWide"])
  write(sorted, "evaluated_jockey")
end

def eval_data(res)
  top_point= 0
  wide_point = 0
  count = res[:count].to_f
  win_rate = res[:winrate].chop.to_f
  wide_rate = res[:widerate].chop.to_f
  top_r_rate = res[:toprecoveryrate].chop.to_f
  wide_r_rate = res[:widerecoveryrate].chop.to_f
  top_point = count * win_rate / 100 * top_r_rate / 100 
  wide_point = count * wide_rate / 100 * wide_r_rate / 100 
  top_raterate = (win_rate * top_r_rate) + count
  wide_raterate = (wide_rate * wide_r_rate) + count
  [top_point.round(), wide_point.round(), top_raterate.round(), wide_raterate.round()]
end

def round_five(result)
  top_points = []
  wide_points = []
  result.each do |res|
    top_points.push res[4].to_f
    wide_points.push res[5].to_f
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

def write(result_evaluated, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    result_evaluated.each do |data|
      csv << data
    end
  end
end

evaluate_jockey()