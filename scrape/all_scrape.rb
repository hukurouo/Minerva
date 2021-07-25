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

@dir_name = "0601yasuda"
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

def search_form
  agent = login()
  search_page = agent.get("https://db.netkeiba.com/?pid=race_search_detail")
  form = search_page.forms[1]

  form["start_year"] = "2019"
  form["start_mon"] = "1"
  form["end_year"] = "2019"
  form["end_mon"] = "1"
  form.checkboxes_with(:name => /jyo/).each_with_index do |field, index|
    break if index == 10
    field.check
  end
  form.checkboxes_with(:name => /track/).each_with_index do |field, index|
    break if index == 2
    field.check
  end
  form["list"] = "100"
  result_page = form.submit()
  p result_page.link_with(:href => /javascript:paging/).click
  write(result_page.content)
end

def write(res)
  File.open("all_data_test.txt", "w") do |data| 
    data << res
  end
end

search_form()