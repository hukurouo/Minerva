require 'nokogiri'
require 'open-uri'
require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

INTERVEL_SEC = 1

header_str = "horseName,date,raceCourse,weather,raceNumber,raceName,horseTotalNumber,frameNumber,horseNumber,oddsNum,oddsRank,rank,jockeyName,weight,courseType,courseLength,courseStatus,coursePoint,time,timeDiff,timePoint,passingOrder,pace,time3f,horseWeight,horseWeightDiff,memo" 
@race_results = [header_str.split(",")]
@dir_name = ARGV[0] #"0502victoriamile"
@url = ARGV[1] #"https://race.netkeiba.com/race/shutuba.html?race_id=202105020811"
@base_race_name = ARGV[2].encode("UTF-8")
if @dir_name.split("/").size() >= 3
  @year = @dir_name.split("/")[1]
else
  @year = "2021"
end

class String
  def sjisable
    str = self
    str = str.encode("euc-jp","UTF-8",:invalid => :replace,:undef=>:replace).encode("UTF-8","euc-jp")
  end
end

def login
  agent = Mechanize.new
  login_page = agent.get("https://regist.netkeiba.com/account/?pid=login")

  form = login_page.forms[1]
  button = form.buttons
  form["login_id"] = ENV["ID"]
  form["pswd"] = ENV["PASS"]

  form.submit()

  agent
end

def get_data_logined_page(url,agent)
  page = agent.get(url)
  table = page.xpath('//table[@class="db_h_race_results nk_tb_common"]/tbody/tr')
  name = page.xpath('//div[@class="horse_title"]').css('h1').text.strip.gsub(/[[:space:]]/, '')
  flag = true # todayはtrue 過去scrapeのときfalse
  table.each_with_index do |tr, index|
    tds = [name]
    
    if (tr.css('td')[4].text == @base_race_name) && tr.css('td')[0].text.include?(@year)
      flag = true
      next
    end

    tr.css('td').each_with_index do |td, index|
      if [0,1,2,3,4,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,25].include?(index)
        tds.push(td.text.strip.sjisable)
      elsif index == 14
        tds.push(td.text[0])
        tds.push(td.text.slice(1...5))
      elsif index == 23
        if td.text.strip.include?("(") 
          tds.push(td.text.split("(")[0])
          tds.push(td.text.split("(")[1].split(")")[0].gsub(/\+/, ''))
        else
          tds.push(td.text.strip)
          tds.push(0)
        end
      end
    end
    @race_results.push tds if flag
  end
  write()
end

def write
  CSV.open("datas/#{@dir_name}/this_year.csv", "w") do |csv| 
    @race_results.each do |data|
      csv << data
    end
  end
end

def get_horse_url(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  table = doc.xpath('//div[@class="RaceTableArea"]/table/tr')
  horse_urls = []

  table.each_with_index do |tr, index|
    race = tr.css('td')[3].css('a')[0][:href]
    horse_urls.push(race)
  end
  horse_urls
end

def main(race_url)
  agent = login()
  urls = get_horse_url(race_url)
  urls.each do |url|
    puts url
    get_data_logined_page(url,agent)
    sleep INTERVEL_SEC
  end
  
  write()
end



main(@url)

