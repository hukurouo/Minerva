require "csv"

def name_arrange(x)
  if x[1].include?("G2") || x[1].include?("G3")
    if x[1].include?("/")
      x[1].split("/")[1].to_f 
    else 
      x[1].to_f
    end
  else
    if x[1].include?("/")
      x[1].split("/")[2].to_f 
    else 
      x[1].to_f
    end
  end
end

def name_split(name)
  if name.include?("G2") || name.include?("G3")
    if name.include?("/")
      name.split("/")[1]
    else 
      name
    end
  else
    if name.include?("/")
      name = name.split("/")[1] + "/" + name.split("/")[2]
    else 
      name
    end
  end
end

data = CSV.table("race_list_done.csv", encoding: "UTF-8")
#data = data.select {|data| data[:racecourse] == "東京"}
#sorted = data.sort_by{|x| name_arrange(x)}

@dir_names = data.map{|x|x[:dirname]}
@result_csv = []
@header = ["title","tan","tan2","huku","wide3box","wide5box","3huku5box","1-2-3oddsRank"]
#@header = ["title","tan","tan2","huku","wide3t","wide3w","wide5t","wide5w","umaren3t","umaren3w","umaren5t","umaren5w","3huku3t","3huku3w","3huku5t","3huku5w","1-2-3oddsRank"]

def performance
  @dir_names.each_with_index do |name, index|
    #next if name == "0504derby"
    #next if (name.include?("G2") || name.include?("G1"))
    next unless name.include?("G3")
    #next if (name.include?("past"))
    #next unless (name.include?("G2"))
    @result_csv_row = [name] 
    top = CSV.table("datas/#{name}/finished_top.csv", encoding: "UTF-8")
    wide = CSV.table("datas/#{name}/finished_wide.csv", encoding: "UTF-8")
    odds = CSV.table("datas/#{name}/odds.csv", encoding: "UTF-8")
    result = CSV.table("datas/#{name}/result.csv", encoding: "UTF-8")
    rank1 = result[0][:odds_rank]
    rank2 = result[1][:odds_rank]
    rank3 = result[2][:odds_rank]
    aggregate(top,wide,odds)
    @result_csv_row.push([rank1,rank2,rank3].join("-"))
    @result_csv.push(@result_csv_row)
  end
  totals = total_calc()
  hit_rates = hit_rate_calc()
  recovery_rates = recovery_calc(totals)
  @result_csv.unshift(["----------"])
  @result_csv.unshift(totals)
  @result_csv.unshift(recovery_rates)
  @result_csv.unshift(hit_rates)
  @result_csv.unshift(["----------"])
  @result_csv.unshift(@header)
  write()
end

def aggregate(top,wide,odds)

  top1 = top[0][:horsenumber]
  top2 = top[1][:horsenumber]
  top3 = top[2][:horsenumber]
  top4 = top[3][:horsenumber]
  top5 = top[4][:horsenumber]


  top5ten = [top1,top2,top3,top4,top5]
  top3ten = [top1,top2,top3]

  wide1 = wide[0][:horsenumber]
  wide2 = wide[1][:horsenumber]
  wide3 = wide[2][:horsenumber]
  wide4 = wide[3][:horsenumber]
  wide5 = wide[4][:horsenumber]

  wide5ten = [wide1,wide2,wide3,wide4,wide5]
  wide3ten = [wide1,wide2,wide3]

  #単勝1点
  rank1 = odds[0][:horsenumber]
  tansyou_odds = odds[0][:odds]
  if top1 == rank1
    @result_csv_row.push tansyou_odds.round()*10 - 1000
  else
    @result_csv_row.push -1000
  end

  #単勝2点
  if top1 == rank1 || top2 == rank1
    @result_csv_row.push tansyou_odds.round()*5 - 1000
  else
    @result_csv_row.push -1000
  end

  #複勝1点
  if top1 == odds[1][:horsenumber]
    @result_csv_row.push odds[1][:odds] * 10 - 1000
  elsif top1 == odds[2][:horsenumber]
    @result_csv_row.push odds[2][:odds] * 10 - 1000
  elsif top1 == odds[3][:horsenumber] && odds[3][:odds]
    @result_csv_row.push odds[3][:odds] * 10 - 1000
  else
    @result_csv_row.push -1000
  end

  #ワイド1点
  #wide_calc([wide1,wide2],odds)

  #ワイド3点BOX(top)
  #wide_calc(top3ten,odds)

  #ワイド3点BOX(wide)
  wide_calc(wide3ten,odds)

  #ワイド4点BOX(wide)
  #wide_calc([wide1,wide2,wide3,wide4],odds)

  #ワイド5点BOX(top)
  #wide_calc(top5ten,odds)

  #ワイド5点BOX(wide)
  wide_calc(wide5ten,odds)

  #馬連3点BOX(top)
  #umaren_calc(top3ten,odds)

  #馬連3点BOX(wide)
  #umaren_calc(wide3ten,odds)

  #馬連5点BOX(top)
  #umaren_calc(top5ten,odds)

  #馬連5点BOX(wide)
  #umaren_calc(wide5ten,odds)

  #三連複3点BOX(top)
  #sanrenhuku_calc(top3ten,odds)

  #三連複3点BOX(wide)
  #sanrenhuku_calc(wide3ten,odds)

  #三連複5点BOX(top)
  #sanrenhuku_calc(top5ten,odds)

  #三連複5点BOX(wide)
  sanrenhuku_calc(wide5ten,odds)
end

def sanrenhuku_calc(box,odds)
  coef = 1
  coef = 3.3 if box.length == 3
  odds = odds[9]
  if is_hit_sanrenhuku?(box,odds)
    @result_csv_row.push (odds[:odds]*coef).round()-1000
  else
    @result_csv_row.push -1000
  end
end

def umaren_calc(box,odds)
  coef = 1
  coef = 3.3 if box.length == 3
  umaren_odds = odds[4]
  if is_hit_wide?(box,umaren_odds)
    @result_csv_row.push (umaren_odds[:odds]*coef).round() - 1000
  else
    @result_csv_row.push -1000
  end
end

def wide_calc(box,odds)
  wide_odds_1 = odds[5]
  wide_odds_2 = odds[6]
  wide_odds_3 = odds[7]
  wide_money = -1000
  coef = 1
  coef = 1.6 if box.length == 4
  coef = 3.3 if box.length == 3
  coef = 10 if box.length == 2
  if is_hit_wide?(box,wide_odds_1)
    wide_money += (wide_odds_1[:odds]*coef).round()
  end
  if is_hit_wide?(box,wide_odds_2)
    wide_money += (wide_odds_2[:odds]*coef).round()
  end
  if is_hit_wide?(box,wide_odds_3)
    wide_money += (wide_odds_3[:odds]*coef).round()
  end
  @result_csv_row.push wide_money
end

def is_hit_wide?(box,wide)
  num1 = wide[:horsenumber].split(",")[0].to_i
  num2 = wide[:horsenumber].split(",")[1].to_i
  box.include?(num1) && box.include?(num2)
end
  
def is_hit_sanrenhuku?(box,odds)
  num1 = odds[:horsenumber].split(",")[0].to_i
  num2 = odds[:horsenumber].split(",")[1].to_i
  num3 = odds[:horsenumber].split(",")[2].to_i
  box.include?(num1) && box.include?(num2) && box.include?(num3)
end

def total_calc()
  col_num = @result_csv[1].length-1
  totals = ["total"]
  (col_num).times do |i|
    next if i == 0
    sum = 0
    @result_csv.each_with_index do |r,j|
      sum += r[i]
    end
    totals.push sum
  end
  totals
end

def hit_rate_calc()
  col_num = @result_csv[1].length-1
  hit_rates = ["hit_rate"]
  (col_num).times do |i|
    next if i == 0
    count = 0
    hit = 0
    @result_csv.each_with_index do |r,j|
      if r[i] != -1000
        hit += 1
        count += 1
      else
        count += 1
      end
    end
    rate = (hit.to_f / count)*100
    hit_rates.push (rate.round(2).to_s + "%")
  end
  hit_rates
end

def recovery_calc(totals)
  totals
  kakekin = @result_csv.length * 1000
  recovery_rates = ["recovery_rate"]
  totals.each_with_index do |t,i|
    next if i == 0
    rate = 100 * (t + kakekin).to_f / kakekin
    recovery_rates.push (rate.round(2).to_s + "%")
  end
  recovery_rates
end

def write
  CSV.open("output_performance.csv", "w") do |csv| 
    @result_csv.each do |data|
      csv << data
    end
  end
end



performance()