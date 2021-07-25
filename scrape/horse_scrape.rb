require 'nokogiri'
require 'open-uri'
require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

INTERVEL_SEC = 1

header_str = "horseName,date,raceCourse,weather,raceNumber,raceName,horseTotalNumber,frameNumber,horseNumber,oddsNum,oddsRank,rank,jockeyName,weight,courseType,courseLength,courseStatus,coursePoint,time,timeDiff,timePoint,passingOrder,pace,time3f,horseWeight,horseWeightDiff,memo" 
@race_results = [header_str.split(",")]
@horse_names  = []

@dir_name = "G3/0708isd"
@races_url = "https://db.netkeiba.com/?pid=race_list&word=%A5%A2%A5%A4%A5%D3%A5%B9%A5%B5%A5%DE%A1%BC%A5%C0%A5%C3%A5%B7%A5%E5&front=1" 
@base_race_name = "アイビスサマーD(G3)" 
@start_years = 1 #過去データ取るときは 2
@years = 15

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
  return if @horse_names.include?(name)
  @horse_names.push name
  flag = false
  table.each_with_index do |tr, index|
    tds = [name]
    tr.css('td').each_with_index do |td, index|
      if index == 4
        if td.text == @base_race_name
          flag = true
        end
      end
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
end

def write
  CSV.open("datas/#{@dir_name}/10years.csv", "w") do |csv| 
    @race_results.each do |data|
      csv << data
    end
  end
end

def get_horse_url(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  table = doc.xpath('//table[@class="race_table_01 nk_tb_common"]/tr')
  race_urls = []

  table.each_with_index do |tr, index|
    next if index == 0
    race = tr.css('td')[3].css('a')[0][:href]
    race_urls.push("https://db.netkeiba.com" + race)
  end
  race_urls
end

def get_race_url(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  table = doc.xpath('//table[@class="nk_tb_common race_table_01"]/tr')
  race_urls = []
  for i in @start_years..@years do
    race = table[i].css('td')[4].css('a')[0][:href]
    race_urls.push("https://db.netkeiba.com" + race)
  end
  race_urls
end

def main(races_url)
  agent = login()
  race_urls = [
    "https://db.netkeiba.com/race/202044070811/",
    "https://db.netkeiba.com/race/201944071011/",
    "https://db.netkeiba.com/race/201844071111/",
    "https://db.netkeiba.com/race/201744071211/",
    "https://db.netkeiba.com/race/201644071311/",
    "https://db.netkeiba.com/race/201544070811/",
    "https://db.netkeiba.com/race/201444070911/",
    "https://db.netkeiba.com/race/201344071011/",
    "https://db.netkeiba.com/race/201244071111/",
    "https://db.netkeiba.com/race/201144071311/",
    "https://db.netkeiba.com/race/201044071411/",
    "https://db.netkeiba.com/race/200944070811/",
    "https://db.netkeiba.com/race/200844070911/",
    "https://db.netkeiba.com/race/200744071111/",
    "https://db.netkeiba.com/race/200644071211/",
  ]
  race_urls = get_race_url(races_url)
  
  race_urls.each do |race_url|
    urls = get_horse_url(race_url)
    
    urls.each do |url|
      puts url
      get_data_logined_page(url,agent)
      sleep INTERVEL_SEC
    end
  end
  
  write()
end

def sandbox(url)
  doc = Nokogiri::HTML.parse(URI.open(url, "r:euc-jp").read)
  year = doc.xpath('//p[@class="smalltxt"]').text.split("年")[0]
  p title
end



#return puts 'URLを指定してください。例）ruby scrape.rb "https://db.netkeiba.com/?pid=race_list&word=%B5%FE%C5%D4%BF%B7%CA%B9%C7%D5&front=1"'  if URI.regexp.match(races_url).nil?

main(@races_url)





