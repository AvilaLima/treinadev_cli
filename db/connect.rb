require 'sequel'
DB = Sequel.connect('sqlite://censo.db') # requires sqlite3

#top 10
=begin
SELECT code, name, population
FROM counties
ORDER BY population
LIMIT 10
=end