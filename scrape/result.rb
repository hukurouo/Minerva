require 'nokogiri'
require 'open-uri'
require "csv"

INTERVEL_SEC = 1

header_str = "rank,horseName,horseNumber,odds_rank" 
@results = [header_str.split(",")]

@odds = [["type","horseNumber","odds"]]

@dir_name = ARGV[0] #"0502victoriamile"
@url = ARGV[1] #"https://race.netkeiba.com/race/shutuba.html?race_id=202105020811&rf=race_submenu"

class String
  def sjisable
    str = self
    str = str.encode("euc-jp","UTF-8",:invalid => :replace,:undef=>:replace).encode("UTF-8","euc-jp")
  end
end

def write(filename, csv_data)
  CSV.open("datas/#{@dir_name}/#{filename}.csv", "w") do |csv| 
    csv_data.each do |data|
      csv << data
    end
  end
end

def get_result(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  table = doc.xpath('//div[@class="ResultTableWrap"]/table/tbody/tr')
  table.each_with_index do |tr, index|
    horse_name = tr.css('td')[3].text.strip.sjisable
    horse_number = tr.css('td')[2].text.strip.sjisable
    rank = tr.css('td')[0].text.strip.sjisable
    odds_rank = tr.css('td')[9].text.strip.sjisable
    @results.push([rank,horse_name,horse_number,odds_rank])
  end

  write("result", @results)

  odds_horse_number = []
  odds_money = []
  odds_type = []

  horse_1 = doc.xpath('//div[@class="ResultTableWrap"]/table/tbody/tr')[0].css('td')[2].text.strip.sjisable
  horse_2 = doc.xpath('//div[@class="ResultTableWrap"]/table/tbody/tr')[1].css('td')[2].text.strip.sjisable
  horse_3 = doc.xpath('//div[@class="ResultTableWrap"]/table/tbody/tr')[2].css('td')[2].text.strip.sjisable

  #単勝
  odds = doc.xpath('//div[@class="ResultTableWrap"]/table/tbody/tr')[0].css('td')[10].text.to_f * 100
  @odds.push(["単勝", horse_1, odds])

  #複勝
  hukusyo_table =  doc.xpath('//tr[@class="Fukusho"]/td')
  hukusyo_odds = hukusyo_table[1].text.split("円").map{|x|x.gsub(/,/, '')}
  hukusyo_num = []
  3.times do |i|
    num = doc.xpath('//div[@class="ResultTableWrap"]/table/tbody/tr')[i].css('td')[2].text.strip.sjisable
    @odds.push(["複勝", num, hukusyo_odds[i]])
  end

  #馬連
  umaren_table =  doc.xpath('//tr[@class="Umaren"]/td')
  umaren_odds = umaren_table[1].text.split("円").map{|x|x.gsub(/,/, '')}[0]
  @odds.push(["馬連", horse_1 + "," + horse_2, umaren_odds])

  #ワイド
  pay_table = doc.xpath('//tr[@class="Wide"]/td')
  pay_table[0].css('ul').each do |wide|
    text = wide.text.split("\n").uniq.compact.join(",")
    text = text.slice(1..text.length-1)
    odds_horse_number.push text
    odds_type.push "ワイド"
  end
  wide_odds = pay_table[1].text.split("円").map{|x|x.gsub(/,/, '')}
  
  odds_horse_number.each_with_index do |odds, i|
    @odds.push([odds_type[i],odds_horse_number[i],wide_odds[i]])
  end

  #馬単
  umatan_table = doc.xpath('//tr[@class="Umatan"]/td')
  umatan_odds = umatan_table[1].text.split("円").map{|x|x.gsub(/,/, '')}[0]
  @odds.push(["馬単", horse_1 + "," + horse_2, umatan_odds])

  #三連複
  huku3_table =  doc.xpath('//tr[@class="Fuku3"]/td')
  huku3_odds = huku3_table[1].text.split("円").map{|x|x.gsub(/,/, '')}[0]
  @odds.push(["三連複", horse_1 + "," + horse_2 + "," + horse_3, huku3_odds])

  #3連単
  tan3_table =  doc.xpath('//tr[@class="Tan3"]/td')
  tan3_odds = tan3_table[1].text.split("円").map{|x|x.gsub(/,/, '')}[0]
  @odds.push(["三連単", horse_1 + "," + horse_2 + "," + horse_3, tan3_odds])

  write("odds", @odds)

end

def main(race_url)
  get_result(race_url)
end

main(@url)