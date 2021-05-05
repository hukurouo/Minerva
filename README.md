## 概要

netkeibaの競馬データをスクレイピングするやつです

## 使用方法

### レース結果データの取得

https://db.netkeiba.com/?pid=race_top

上のURLで取得したいレースの名前で検索して、結果のURLをコピーします。


コマンドラインで `ruby scrape.rb "URL"`を実行すると、`output.csv`に結果が出力されます。

~~~
ruby scrape.rb "https://db.netkeiba.com/?pid=race_list&word=%B5%FE%C5%D4%BF%B7%CA%B9%C7%D5&front=1"
~~~

降着や失格扱いの場合は、順位欄には99が入ります。