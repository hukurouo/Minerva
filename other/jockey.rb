"type,first,second,third,beyond3,count,winRate,win2Rate,wideRate,topRecoveryRate,wideRecoveryRate"

id = "01051"
text = File.read("datas/jockey/textdata/#{id}.txt", encoding: 'UTF-8')
text = text.split(/\R/)
csv_data = ["type,first,second,third,beyond3,count,winRate,win2Rate,wideRate,topRecoveryRate,wideRecoveryRate".split(",")]
text.each do |t|
  csv_data << t.split("\t")
end
require "csv"
CSV.open("datas/jockey/csv/#{id}.csv", "w") do |csv| 
  csv_data.each do |data|
    csv << data
  end
end