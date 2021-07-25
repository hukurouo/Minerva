require "csv"

data = CSV.table("race_list_done.csv", encoding: "UTF-8")

g3items2020 = []
g3items2019 = []

data.each do |d|
  if d[:dirname].include?("G3") && (d[:id].to_f < 87)  
    g3items2020.push d 
  elsif d[:dirname].include?("G3") && (d[:id].to_f >= 87) && (d[:id].to_f < 111) 
    g3items2019.push d 
  end
end

id = 310

g3items2019.each do |g|
  [0,1,2].each do |index|
    csv_row = [
      id,
      "past/#{2019-index}/" + g[:dirname],
      g[:racename],
      g[:racetype],
      g[:racecourse],
      g[:direction],
      g[:raceid]
    ]
    CSV.open('race_list_done.csv','a') do |csv| 
      csv << csv_row
    end
    id += 1
  end
end
