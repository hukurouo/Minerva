
dir_name = "0501nhkmile"
card_url = "https://race.netkeiba.com/race/shutuba.html?race_id=202105020611"
races_url = "https://db.netkeiba.com/?pid=race_list&word=%A3%CE%A3%C8%A3%CB%A5%DE%A5%A4%A5%EB%A5%AB%A5%C3%A5%D7&front=1"
base_race_name = "NHKマイルC(G1)"

system("ruby scrape/card.rb '#{dir_name}' '#{card_url}' ")
system("ruby scrape/this_year.rb '#{dir_name}' '#{card_url}' '#{base_race_name}'")

