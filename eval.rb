#dir_name = "0501nhkmile"
#base_race_name = "NHKマイルC(G1)"
#race_type_m = "芝1600m"
#race_type_b = "東京"
#direction = "left"

require "csv"

data = CSV.table("race_list_done.csv", encoding: "UTF-8")

data.each do |d|
  if 382 <= d[:id] && d[:id] <= 382 #d[:id] == 211
    dir_name = d[:dirname]
    base_race_name = d[:racename]
    race_type_m = d[:racetype]
    race_type_b = d[:racecourse]
    direction = d[:direction]

    #system("ruby prepare/frame_number_arrange.rb '#{dir_name}' '#{base_race_name}' ")
    #system("ruby prepare/result_prepare.rb '#{dir_name}' '#{base_race_name}'")

    system("ruby evaluate/evaluate_result.rb '#{dir_name}'")
    #system("ruby evaluate/evaluate_jockey.rb '#{dir_name}' '#{race_type_m}' '#{race_type_b}'")
    #system("ruby evaluate/evaluate_time_point.rb '#{dir_name}'")
    #system("ruby evaluate/evaluate_race.rb '#{dir_name}' '#{direction}'")
    system("ruby evaluate/modify_name.rb '#{dir_name}'")
    #system("ruby evaluate/evaluate_finish.rb '#{dir_name}' 1.0 1.4 0.8 0.8 0.4")
    p "done" + dir_name
  end
end

