require "csv"
require 'date'

# 定数
@horse_coef = 1.0
@jockey_coef = 1.0
@frame_coef = 0.4
@time_coef = 0.8
@race_coef = 1

def update
  data = CSV.table("race_list_done.csv", encoding: "UTF-8")
  data.each do |d|
    #next if d[:id] != 1
    dir_name = d[:dirname]
    base_race_name = d[:racename]
    race_type_m = d[:racetype]
    race_type_b = d[:racecourse]
    direction = d[:direction]

    #system("ruby evaluate/evaluate_result.rb '#{dir_name}'")
    #system("ruby evaluate/evaluate_jockey.rb '#{dir_name}' '#{race_type_m}' '#{race_type_b}'")
    #system("ruby evaluate/evaluate_time_point.rb '#{dir_name}'")
    #system("ruby evaluate/evaluate_race.rb '#{dir_name}' '#{direction}'")
    #system("ruby evaluate/modify_name.rb '#{dir_name}'")
    system("ruby evaluate/evaluate_finish.rb '#{dir_name}' #{@horse_coef} #{@jockey_coef} #{@frame_coef} #{@time_coef} #{@race_coef}")
  end
  p "done"
  system("ruby performance.rb")
end

def write
  performance =  CSV.table("output_performance.csv", encoding: "UTF-8")
  hit = performance[1]
  rec = performance[2]
  tot = performance[3]
  
  file = File.open('log.txt','a')

  t = Time.now

  coef = ["horse",@horse_coef,"jock",@jockey_coef,"frame",@frame_coef,"time",@time_coef,"race",@race_coef].join(" ")

  file.puts t
  file.puts coef
  file.puts hit.to_a.join(",")
  file.puts rec.to_a.join(",")
  file.puts ""
  file.close
end

def write_csv
  performance =  CSV.table("output_performance.csv", encoding: "UTF-8")
  hit = performance[1]
  rec = performance[2]
  csv_row = [@horse_coef,@jockey_coef,@frame_coef,@time_coef,@race_coef]
  csv_row2 = [@horse_coef,@jockey_coef,@frame_coef,@time_coef,@race_coef]
  hit.each_with_index do |h,i|
    next if i == 0
    csv_row.push h[1].strip
  end
  rec.each_with_index do |r,i|
    next if i == 0
    csv_row2.push r[1].strip
  end

  CSV.open('results/hit_log.csv','a') do |csv| 
    csv << csv_row
  end

  CSV.open('results/rec_log.csv','a') do |csv| 
    csv << csv_row2
  end
end

def auto
  [0.2,0.4,0.6,0.8,1.0].each do |i|
    [0.2,0.4,0.6,0.8,1.0].each do |j|
      [0.2,0.4,0.6,0.8,1.0].each do |k|
        @frame_coef = i
        @time_coef = j
        @race_coef = k 
        update()
        write_csv()
      end
    end
  end
end

auto()
#update()
#write_csv()
