require "csv"

@dir_name = ARGV[0]

def add_odds_rank
  result = CSV.table("datas/#{@dir_name}/result.csv", encoding: "UTF-8")
  top = CSV.table("datas/#{@dir_name}/finished_top.csv", encoding: "UTF-8")
  wide = CSV.table("datas/#{@dir_name}/finished_wide.csv", encoding: "UTF-8")

  map = {}

  result.each do |r|
    map.store(r[:horsename],[r[:odds_rank],r[:rank]])
  end

  new_top = upsert_odds_rank(top,map)
  new_wide = upsert_odds_rank(wide,map)
  write(new_top,"finished_top")
  write(new_wide,"finished_wide")
end

def upsert_odds_rank(top,map)
  new_top = [["horseNumber","horseName","jockeyName","totalPoint","horsePoint","jockeyPoint","framePoint","timePoint","racePoint","roubdTotalPoint","oddsRank","rank"]]

  top.each do |t|
    odds_rank = 0
    rank = 0
    map.each do |m|
      if t[:horsename].include? m[0]
        odds_rank = m[1][0]
        rank = m[1][1]
      end
    end
    t.push odds_rank
    t.push rank
    new_top.push t
  end

  new_top
end

def write(result_evaluated, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    result_evaluated.each do |data|
      csv << data
    end
  end
end

add_odds_rank()