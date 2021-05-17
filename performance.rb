require "csv"

def name_arrange(x)
  if x[1].include?("/")
    x[1].split("/")[1].to_f 
  else 
    x[1].to_f
  end
end

def name_split(name)
  if name.include?("/")
    name.split("/")[1]
  else 
    name
  end
end

data = CSV.table("race_list_done.csv", encoding: "UTF-8")
sorted = data.sort_by{|x| name_arrange(x)}



@dir_names = sorted.map{|x|x[:dirname]}
@result_csv = []
@header = ["title","tan","tan2","huku","wide3t","wide3w","wide5t","wide5w","umaren3t","umaren3w","umaren5t","umaren5w","3huku5t","3huku5w"]

def performance
  @dir_names.each do |name|
    @result_csv_row = [name_split(name)] 
    top = CSV.table("datas/#{name}/finished_top.csv", encoding: "UTF-8")
    wide = CSV.table("datas/#{name}/finished_wide.csv", encoding: "UTF-8")
    odds = CSV.table("datas/#{name}/odds.csv", encoding: "UTF-8")
    aggregate(top,wide,odds)
    @result_csv.push(@result_csv_row)
  end
  totals = total_calc()
  recovery_rates = recovery_calc(totals)
  @result_csv.unshift(["----------"])
  @result_csv.unshift(totals)
  @result_csv.unshift(recovery_rates)
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
  elsif top1 == odds[3][:horsenumber]
    @result_csv_row.push odds[3][:odds] * 10 - 1000
  else
    @result_csv_row.push -1000
  end

  #ワイド3点BOX(top)
  wide_calc(top3ten,odds)

  #ワイド3点BOX(wide)
  wide_calc(wide3ten,odds)

  #ワイド5点BOX(top)
  wide_calc(top5ten,odds)

  #ワイド5点BOX(wide)
  wide_calc(wide5ten,odds)

  #馬連3点BOX(top)
  umaren_calc(top3ten,odds)

  #馬連3点BOX(wide)
  umaren_calc(wide3ten,odds)

  #馬連5点BOX(top)
  umaren_calc(top5ten,odds)

  #馬連5点BOX(wide)
  umaren_calc(wide5ten,odds)

  #三連複5点BOX(top)
  sanrenhuku_calc(top5ten,odds)

  #三連複5点BOX(wide)
  sanrenhuku_calc(wide5ten,odds)
end

def sanrenhuku_calc(box,odds)
  odds = odds[9]
  if is_hit_sanrenhuku?(box,odds)
    @result_csv_row.push odds[:odds]-1000
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
  coef = 3.3 if box.length == 3
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
  col_num = @result_csv[1].length
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