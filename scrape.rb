
require "csv"

data = CSV.table("race_list_done.csv", encoding: "UTF-8")

data.each do |d|
  if 382 <= d[:id] && d[:id] <= 382
    dir_name = d[:dirname]
    base_race_name = d[:racename]
    card_url = "https://race.netkeiba.com/race/shutuba.html?race_id=" + d[:raceid].to_s
    result_url = "https://race.netkeiba.com/race/result.html?race_id=" + d[:raceid].to_s

    #system("ruby scrape/card.rb '#{dir_name}' '#{card_url}' ")
    #system("ruby scrape/this_year.rb '#{dir_name}' '#{card_url}' '#{base_race_name}'")
    #system("ruby scrape/data.rb '#{dir_name}' '#{d[:raceid].to_s}'")
    #system("ruby scrape/ten_years_update.rb '#{dir_name}' '#{base_race_name}'")
    #system("ruby scrape/result.rb '#{dir_name}' '#{result_url}'")
    #system("ruby other/add_odds_rank.rb '#{dir_name}'")
    system("ruby other/add_odds_rank_g3.rb '#{dir_name}'")

    p "done" + dir_name
  end
end

