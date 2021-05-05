require 'nokogiri'
require 'open-uri'

INTERVEL_SEC = 3

header_str = "raceName,year,rank,frameNumber,horseNumber,horseName,sexualAge,weight,jockeyName,time,passingOrder,time3f,oddsNum,oddsRank,horseWeight,horseWeightDiff,trainerName" 
@race_results = [header_str.split(",")]

def getData(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  table = doc.xpath('//table[@class="race_table_01 nk_tb_common"]/tr')
  title = doc.xpath('//dl[@class="racedata fc"]').css('h1').text
  year = doc.xpath('//p[@class="smalltxt"]').text.split("年")[0]

  table.each_with_index do |tr, index|
    next if index == 0
    tds = [title, year]
    tr.css('td').each_with_index do |td, index|
      if [1,2,3,4,5,6,7,10,11,12,13].include?(index)
        tds.push(td.text.strip)
      elsif index == 0
        if td.text.strip.include?("降") || td.text.strip.include?("中") || td.text.strip.include?("失")
          tds.push(99)
        else
          tds.push(td.text.strip)
        end
      elsif index == 14
        tds.push(td.text.split("(")[0])
        tds.push(td.text.split("(")[1].split(")")[0].gsub(/\+/, ''))
      elsif index == 18
        tds.push(td.text.split("\n")[2])
      end
    end
    @race_results.push(tds)
  end
end

def write
  File.open("output.csv", "w") do |f| 
    @race_results.each do |data|
      f.puts(data.join(",") + "\n")
    end
  end
end

def get_race_url(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  table = doc.xpath('//table[@class="nk_tb_common race_table_01"]/tr')
  race_urls = []
  for i in 1..20 do
    race = table[i].css('td')[4].css('a')[0][:href]
    race_urls.push("https://db.netkeiba.com" + race)
  end

  race_urls
end

def main(races_url)
  urls = get_race_url(races_url)
  urls.each do |url|
    puts url
    getData(url)
    sleep INTERVEL_SEC
  end
  write()
end

def sandbox(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  year = doc.xpath('//p[@class="smalltxt"]').text.split("年")[0]
  p title
end

races_url = ARGV[0]

return puts 'URLを指定してください。例）ruby scrape.rb "https://db.netkeiba.com/?pid=race_list&word=%B5%FE%C5%D4%BF%B7%CA%B9%C7%D5&front=1"'  if URI.regexp.match(races_url).nil?

main(races_url)






