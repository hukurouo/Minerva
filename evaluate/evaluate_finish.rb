require "csv"

# 定数
@horse_coef = 1
@jockey_coef = 1
@frame_coef = 0.4
@time_coef = 0.4
@race_coef = 1
@dir_name = ARGV[0] 


def evaluate_finished
  jockey_eval = CSV.table("datas/#{@dir_name}/evaluated_jockey.csv", {:encoding => "UTF-8"})
  result_eval = CSV.table("datas/#{@dir_name}/evaluated_result.csv", {:encoding => "UTF-8"})
  frame_eval = CSV.table("datas/#{@dir_name}/evaluated_frame_number.csv", {:encoding => "UTF-8"})
  time_eval = CSV.table("datas/#{@dir_name}/evaluated_timepoint.csv", {:encoding => "UTF-8"})
  race_eval = CSV.table("datas/#{@dir_name}/evaluated_racepoint.csv", {:encoding => "UTF-8"})
  card = CSV.table("datas/#{@dir_name}/this_year_card.csv", {:encoding => "UTF-8"})
  

  finished = {}
  card.each do |r|
    finished.store(r[:horsename],{top: [], wide: [], jockey: r[:jockeyname], horsenumber: r[:horsenumber]})
  end
  result_eval.each do |r|
    finished[r[:horsename]][:top].push(r[:roundtop])
    finished[r[:horsename]][:wide].push(r[:roundwide])
  end
  jockey_eval.each do |r|
    finished[r[:horsename]][:top].push(r[:roundtop])
    finished[r[:horsename]][:wide].push(r[:roundwide])
  end
  frame_eval.each do |r|
    frame_num = r[:framenumber]
    horse_names = []
    card.each do |c|
      if c[:framenumber] == frame_num
        horse_names.push c[:horsename]
      end
    end
    horse_names.each do |h|
      finished[h][:top].push(r[:roundtop])
      finished[h][:wide].push(r[:roundwide])
    end
  end
  time_eval.each do |r|
    finished[r[:horsename]][:top].push(r[:round])
    finished[r[:horsename]][:wide].push(r[:round])
  end
  race_eval.each do |r|
    finished[r[:horsename]][:top].push(r[:round])
    finished[r[:horsename]][:wide].push(r[:round])
  end

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
  sorted = finished_csv_top.sort_by{|x| x[3]*-1 }
  sorted2 = finished_csv_wide.sort_by{|x| x[3]*-1 }
  sorted.unshift(["horseNumber","horseName","jockeyName","totalPoint","horsePoint","jockeyPoint","framePoint","timePoint","racePoint"])
  sorted2.unshift(["horseNumber", "horseName","jockeyName","totalPoint","horsePoint","jockeyPoint","framePoint","timePoint","racePoint"])
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

def write(result_evaluated, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    result_evaluated.each do |data|
      csv << data
    end
  end
end

evaluate_finished()