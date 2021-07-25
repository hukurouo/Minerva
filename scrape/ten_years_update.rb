require "csv"

@dir_name = ARGV[0] #"0502victoriamile" past/2020/0503oaks past/2019/G3/0105kyoto
@base_race_name = ARGV[1].encode("UTF-8") #"ヴィクトリアマイル(G1)"
@years = ["2021","2020","2019","2018","2017","2016"]

def update_tenyears()
  year = @dir_name.split("/")[1]
  dir_name = @dir_name
  if dir_name.include?("past") && dir_name.include?("2020")
    dir_name = "G3/" + dir_name.split("/")[3]
  else
    tmp = dir_name.split("/")
    tmp[1] = (tmp[1].to_i + 1).to_s
    dir_name = tmp.join("/")
  end
  data = CSV.table("datas/#{dir_name}/10years.csv", encoding: "UTF-8")
  new_csv = ["horseName,date,raceCourse,weather,raceNumber,raceName,horseTotalNumber,frameNumber,horseNumber,oddsNum,oddsRank,rank,jockeyName,weight,courseType,courseLength,courseStatus,coursePoint,time,timeDiff,timePoint,passingOrder,pace,time3f,horseWeight,horseWeightDiff,memo".split(",")]
  horse_name = ""
  flag = false
  data.each do |d|
    if horse_name != d[:horsename]
      flag = false
    end
    horse_name = d[:horsename]

    if ((d[:date].include?(year) || d[:date].include?("2021")) && d[:racename] == @base_race_name)
      flag = true
    end

    if (!d[:date].include?(year) && !d[:date].include?("2021") && d[:racename] == @base_race_name)
      flag = false
    end

    next if flag
    new_csv.push(d)
  end
  write(new_csv, "10years")
end

def write(result_evaluated, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    result_evaluated.each do |data|
      csv << data
    end
  end
end

update_tenyears()