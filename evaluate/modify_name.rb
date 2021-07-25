require "csv"

@dir_name = ARGV[0] 


def modify_name
  jockey_eval = CSV.table("datas/#{@dir_name}/evaluated_jockey.csv", {:encoding => "UTF-8"})
  time_eval = CSV.table("datas/#{@dir_name}/evaluated_result.csv", {:encoding => "UTF-8"})
  card = CSV.table("datas/#{@dir_name}/this_year_card.csv", {:encoding => 'UTF-8', :converters => nil})
  data_eval = CSV.table("datas/#{@dir_name}/today_data.csv", {:encoding => "UTF-8"})

  valid_names = time_eval[:horsename]
  
  valid_jockey_csv = []

  jockey_eval.each do |d|
    valid_horse_name = ""
    valid_names.each do |v|
      if v.include? d[:horsename]
        valid_horse_name = v
      end
    end
    csv_row = []
    d.each do |c|
      csv_row.push c[1]
    end
    csv_row[0] = valid_horse_name
    valid_jockey_csv.push csv_row
  end

  valid_jockey_csv.unshift(["horseName","jockeyname","topPoint","WidePoint","topRatePoint","wideRatePoint","roundTop","roundWide"])
  write(valid_jockey_csv, "evaluated_jockey")

  valid_card_csv = []

  card.each do |d|
    valid_horse_name = ""
    valid_names.each do |v|
      if v.include? d[:horsename]
        valid_horse_name = v
      end
    end
    csv_row = []
    d.each do |c|
      csv_row.push c[1]
    end
    csv_row[0] = valid_horse_name
    valid_card_csv.push csv_row
  end

  valid_data_csv = []

  data_eval.each do |d|
    valid_horse_name = ""
    valid_names.each do |v|
      if v.include? d[:horsename]
        valid_horse_name = v
      end
    end
    csv_row = []
    d.each do |c|
      csv_row.push c[1]
    end
    csv_row[0] = valid_horse_name
    valid_data_csv.push csv_row
  end

  valid_card_csv.unshift("horseName,frameNumber,jockeyName,jockeyId,horseNumber".split(","))
  write(valid_card_csv, "this_year_card")

  valid_data_csv.unshift("horseName,horseId,oikiri,comment,timePointTop,timePointWide,timePointTotal,rankPoint,tyakusaPoint".split(","))
  write(valid_data_csv, "today_data")

end

def write(result_evaluated, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    result_evaluated.each do |data|
      csv << data
    end
  end
end


modify_name()