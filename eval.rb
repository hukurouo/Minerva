dir_name = "0501nhkmile"
base_race_name = "NHKマイルC(G1)"
race_type_m = "芝1600m"
race_type_b = "東京"

system("ruby prepare/frame_number_arrange.rb '#{dir_name}' '#{base_race_name}' ")
system("ruby prepare/result_prepare.rb '#{dir_name}' '#{base_race_name}'")

system("ruby evaluate/evaluate_result.rb '#{dir_name}'")
system("ruby evaluate/evaluate_jockey.rb '#{dir_name}' '#{race_type_m}' '#{race_type_b}'")
system("ruby evaluate/time_point_eval.rb '#{dir_name}'")
system("ruby evaluate/evaluate_finish.rb '#{dir_name}'")
