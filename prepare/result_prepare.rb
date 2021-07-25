require "csv"

header_str = "raceName,arrange1,arrange2,arrange3,topPoint1,widePoint1,topPoint2,widePoint2,topPoint3,widePoint3" 
@result_arrange_data = [header_str.split(",")]

@dir_name = ARGV[0] #"0502victoriamile"
@base_race_name = ARGV[1].encode("UTF-8") #"ヴィクトリアマイル(G1)"

def result_prepare
  data = CSV.table("datas/#{@dir_name}/10years.csv", encoding: "UTF-8")
  base_race_name = race_name_strip(@base_race_name)
  race_names = data[:racename].uniq

  race_names.each do |race_name|
    race_name = race_name_strip(race_name)
    #next if race_name == base_race_name 
    race_horse_name_list = []
    hash = {}
    result = []
    data.each do |d|
      if race_name_strip(d[:racename]) == race_name
        race_horse_name_list.push d[:horsename]
        hash.store(d[:horsename], d[:rank])
      end
    end
    data.each do |d|
      if race_name_strip(d[:racename]) == base_race_name && race_horse_name_list.include?(d[:horsename])
        race_rank = hash[d[:horsename]]
        base_race_rank = d[:rank]
        if /\d/.match?(race_rank.to_s) && /\d/.match?(base_race_rank.to_s)
          result.push({race_rank: race_rank, base_race_rank: base_race_rank})
        end
      end
    end

    result_arange = [race_name]
    over_one = [0,0,0,0]
    over_three = [0,0,0,0]
    beyond_three = [0,0,0,0]
    result.each do |res|
      if res[:race_rank] == 1
        over_one = set_result_arrange(res[:base_race_rank], over_one)
        over_three = set_result_arrange(res[:base_race_rank], over_three)
      elsif res[:race_rank] == 2 || res[:race_rank] == 3
        over_three = set_result_arrange(res[:base_race_rank], over_three)
      else
        beyond_three = set_result_arrange(res[:base_race_rank], beyond_three)
      end
    end

    perc_over_one = percent_calc(over_one)
    perc_over_three = percent_calc(over_three)
    perc_beyond_three = percent_calc(beyond_three)

    result_arange.push(
      over_one.join("-"), 
      over_three.join("-"), 
      beyond_three.join("-"),
      perc_over_one[0],
      perc_over_one[1],
      perc_over_three[0],
      perc_over_three[1],
      perc_beyond_three[0],
      perc_beyond_three[1]
    )

    @result_arrange_data.push(result_arange)
  end

  write()
  
end

def race_name_strip(race_name)
  if race_name.include? "("
    race_name = race_name.split("(")[0]
  else
    race_name
  end
end

def set_result_arrange(base_rank, iremono)
  if base_rank == 1
    iremono[0] = iremono[0] + 1
  elsif base_rank == 2
    iremono[1] = iremono[1] + 1
  elsif base_rank == 3
    iremono[2] = iremono[2] + 1
  else 
    iremono[3] = iremono[3] + 1
  end
  return iremono
end

def percent_calc(iremono)
  sum = iremono.sum
  sum = 1 if sum == 0
  perc1 = (iremono[0].to_f / sum) 
  perc3 = ((iremono[0]+iremono[1]+iremono[2]).to_f / sum) 
  perc = [perc1.round(2), perc3.round(2)]
end

def write
  CSV.open("datas/#{@dir_name}/result_arrange.csv", "w") do |csv| 
    @result_arrange_data.each do |data|
      csv << data
    end
  end
end

result_prepare
