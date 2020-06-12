=begin
require "csv"
CSV.foreach("db/censo_2019.csv") do |row|
  puts row
end
=end
require 'csv'
csv_text = File.read('db/censo_2019.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|

end