require "csv"

@dir_name = ARGV[0] 

# 定数
@horse_coef = ARGV[1].to_f  #1
@jockey_coef = ARGV[2].to_f  #1
@frame_coef = ARGV[3].to_f  #0.4
@time_coef = ARGV[4].to_f #0.4
@race_coef = ARGV[5].to_f  #1

def evaluate_finished
  jockey_eval = CSV.table("datas/#{@dir_name}/evaluated_jockey.csv", {:encoding => "UTF-8"})
  result_eval = CSV.table("datas/#{@dir_name}/evaluated_result.csv", {:encoding => "UTF-8"})
  time_eval = CSV.table("datas/#{@dir_name}/evaluated_timepoint.csv", {:encoding => "UTF-8"})
  race_eval = CSV.table("datas/#{@dir_name}/evaluated_racepoint.csv", {:encoding => "UTF-8"})
  card = CSV.table("datas/#{@dir_name}/this_year_card.csv", {:encoding => "UTF-8"})
  data = CSV.table("datas/#{@dir_name}/today_data.csv", {:encoding => "UTF-8"})
  #horseName,horseId,oikiri,comment,timePointTop,timePointWide,timePointTotal,rankPoint,tyakusaPoint

  dir_name = @dir_name
  if dir_name.include?("past")
    dir_name = dir_name.split("/")[2]
  end
  #frame_eval = CSV.table("datas/#{dir_name}/evaluated_frame_number.csv", {:encoding => "UTF-8"})

  finished = {}
  card.each do |r|
    finished.store(r[:horsename],{top: [], wide: [], jockey: r[:jockeyname], horsenumber: r[:horsenumber]})
  end
  result_eval.each do |r|
    begin
      finished[r[:horsename]][:top].push(r[:roundtop])
    rescue
      p @dir_name
      p r[:horsename]
    end
    finished[r[:horsename]][:wide].push(r[:roundwide])
  end
  jockey_eval.each do |r|
    finished[r[:horsename]][:top].push(r[:roundtop])
    finished[r[:horsename]][:wide].push(r[:roundwide])
  end
  data.each do |d|
    #horseName,horseId,oikiri,comment,timePointTop,timePointWide,timePointTotal,rankPoint,tyakusaPoint
    round_oikiri = d[:oikiri].to_f / 10
    round_comment = d[:comment].to_f / 10
    round_time_top = d[:timepointtop].to_f / 2
    round_time_wide = d[:timepointwide].to_f / 5
    begin
      finished[d[:horsename]][:top].push(round_oikiri, round_comment, round_time_top)
      finished[d[:horsename]][:wide].push(round_oikiri, round_comment, round_time_wide)
    rescue
      p @dir_name
    end
  end
  #frame_eval.each do |r|
  #  frame_num = r[:framenumber]
  #  horse_names = []
  #  card.each do |c|
  #    if c[:framenumber] == frame_num
  #      horse_names.push c[:horsename]
  #    end
  #  end
  #  horse_names.each do |h|
  #    finished[h][:top].push(r[:roundtop])
  #    finished[h][:wide].push(r[:roundwide])
  #  end
  #end
  #time_eval.each do |r|
  #  finished[r[:horsename]][:top].push(r[:round])
  #  finished[r[:horsename]][:wide].push(r[:round])
  #end
  #race_eval.each do |r|
  #  finished[r[:horsename]][:top].push(r[:round])
  #  finished[r[:horsename]][:wide].push(r[:round])
  #end

  finished_csv_top = []
  finished_csv_wide = []

  finished.each do |data|
    horse_name = data[0]
    jockey_name = data[1][:jockey]
    horse_number = data[1][:horsenumber]

    top = data[1][:top]
    wide = data[1][:wide]

    finished_csv_top = sum_proc(horse_number, horse_name, jockey_name, top, finished_csv_top)
    finished_csv_wide = sum_proc(horse_number, horse_name, jockey_name, wide, finished_csv_wide)
    
  end
  finished_csv_top = round_five(finished_csv_top)
  finished_csv_wide = round_five(finished_csv_wide)
  sorted = finished_csv_top.sort_by{|x| x[3]*-1 }
  sorted2 = finished_csv_wide.sort_by{|x| x[3]*-1 }
  sorted.unshift(["horseNumber","horseName","jockeyName","totalPoint","horsePoint","jockeyPoint","oikiriPoint","stablePoint","timePoint","roubdTotalPoint"])
  sorted2.unshift(["horseNumber", "horseName","jockeyName","totalPoint","horsePoint","jockeyPoint","oikiriPoint","stablePoint","timePoint","roubdTotalPoint"])
  write(sorted, "finished_top")
  write(sorted2, "finished_wide")
end

def sum_proc(horse_number, horse_name, jockey_name, data, finished_csv)
  horse_point = data[0].to_f
  jockey_point = data[1].to_f
  frame_point = data[2].to_f
  time_point = data[3].to_f
  race_point = data[4].to_f

  total = horse_point * @horse_coef + jockey_point * @jockey_coef + frame_point * @frame_coef + time_point * @time_coef + race_point * @race_coef

  finished_csv.push([horse_number, horse_name, jockey_name, total.round(2), horse_point, jockey_point, frame_point, time_point, race_point])
  finished_csv
end

def round_five(result)
  time_points = []
  result.each do |res|
    time_points.push res[3].to_f
  end

  max = time_points.max

  div_num = max.to_f / 5

  five_rounds = time_points.map{|x|(x / div_num).round(2)}
  
  result.each_with_index do |res, i|
    res.push(five_rounds[i])
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

evaluate_finished()