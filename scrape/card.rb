require 'nokogiri'
require 'open-uri'
require "csv"

INTERVEL_SEC = 1

header_str = "horseName,frameNumber,jockeyName,jockeyId,horseNumber" 
@results = [header_str.split(",")]

@dir_name = ARGV[0] #"0502victoriamile"
@url = ARGV[1] #"https://race.netkeiba.com/race/shutuba.html?race_id=202105020811&rf=race_submenu"

class String
  def sjisable
    str = self
    str = str.encode("euc-jp","UTF-8",:invalid => :replace,:undef=>:replace).encode("UTF-8","euc-jp")
  end
end

def write
  CSV.open("datas/#{@dir_name}/this_year_card.csv", "w") do |csv| 
    @results.each do |data|
      csv << data
    end
  end
end

def get_horse_url(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  table = doc.xpath('//div[@class="RaceTableArea"]/table/tr')
  table.each_with_index do |tr, index|
    jockey_id = tr.css('td')[6].css('a')[0][:href].split("/")[4].to_s
    jockey_name = tr.css('td')[6].text.strip.sjisable
    horse_name = tr.css('td')[3].text.strip.sjisable
    frame_number = tr.css('td')[0].text.strip.sjisable
    horse_number = tr.css('td')[1].text.strip.sjisable
    @results.push([horse_name,frame_number,jockey_name,jockey_id,horse_number])
  end
end

def main(race_url)
  get_horse_url(race_url)
  write()
end

main(@url)