require "csv"
require 'date'

# 定数 v1.0,1.0,0.6,0.4,0.8 v0.2,0.0,0.5
#g1
#1.0,1.0,0.6,0.0,0.2,207.83%,172.91%,102.61%,135.5%,157.62%,214.8%
#g3単勝
#1.0,1.4,0.0,0.0,0.0,195.18%,147.5%,86.96%,61.58%,116.79%,193.75%
#g3ワイド
#1.0,1.4,0.8,0.8,0.4,19.64%,39.29%,39.29%,26.79%,69.64%,17.86%
#g3単勝v2
# 0.4 1.2 1.0 0.5 0.3

#g3ワイド
#1.0,1.4,0.8,0.8,0.4,19.64%,39.29%,39.29%,26.79%,69.64%,17.86%
@horse_coef, @jockey_coef, @frame_coef, @time_coef, @race_coef = 1.0, 1.4, 0.8, 0.8, 0.4
#g3単勝v2
# 0.4 1.2 1.0 0.5 0.3
#@horse_coef, @jockey_coef, @frame_coef, @time_coef, @race_coef = 0.4, 1.2, 1.0, 0.5, 0.3

def update
  data = CSV.table("race_list_done.csv", encoding: "UTF-8")
  data.each do |d|
    #next if d[:racecourse] != "東京"
    if 382 <= d[:id] && d[:id] <= 382
      #next if (d[:dirname].include?("G2") || d[:dirname].include?("G1"))
      #next unless d[:dirname].include?("G2") 
      next unless d[:dirname].include?("G3")
      dir_name = d[:dirname]
      base_race_name = d[:racename]
      race_type_m = d[:racetype]
      race_type_b = d[:racecourse]
      direction = d[:direction]
      #system("ruby prepare/result_prepare.rb '#{dir_name}' '#{base_race_name}'")
      #system("ruby evaluate/evaluate_result.rb '#{dir_name}'")
      #system("ruby evaluate/evaluate_jockey.rb '#{dir_name}' '#{race_type_m}' '#{race_type_b}'")
      #system("ruby evaluate/evaluate_time_point.rb '#{dir_name}'")
      #system("ruby evaluate/evaluate_race.rb '#{dir_name}' '#{direction}'")
      #system("ruby evaluate/modify_name.rb '#{dir_name}'")
      #system("ruby evaluate/evaluate_finish_g3.rb '#{dir_name}' #{@horse_coef} #{@jockey_coef} #{@frame_coef} #{@time_coef} #{@race_coef}")
      system("ruby evaluate/evaluate_finish.rb '#{dir_name}' #{@horse_coef} #{@jockey_coef} #{@frame_coef} #{@time_coef} #{@race_coef}")
    end
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
    next unless h[1]
    csv_row.push h[1].strip
  end
  rec.each_with_index do |r,i|
    next if i == 0
    next unless r[1]
    csv_row.push r[1].strip
  end

  CSV.open('results/all_log.csv','a') do |csv| 
    csv << csv_row
  end

  #CSV.open('results/rec_log.csv','a') do |csv| 
  #  csv << csv_row2
  #end
end

# 1.0,1.0,0.2,0.0,0.4 / 0.0,0.3,0.6,0.9 / 1.4,1.2,1.0,0.8,0.6
# 0.5 1.0 1.0 0.5 0
def auto
  [0.2,0.4,0.6].each do |i|
    [0.8,1.0,1.2].each do |j|
      [0.6,0.8,1.0].each do |k|
        [0.3,0.5,0.7].each do |l|
          [0.3,0.5,0.7].each do |m|
            @horse_coef = i
            @jockey_coef = j
            @frame_coef = k
            @time_coef = l
            @race_coef = m
            update()
            write_csv()
          end
        end
      end
    end
  end
end

#auto()
update()
write_csv()
