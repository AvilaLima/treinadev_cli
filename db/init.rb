require 'sequel'
require 'csv'


DB = Sequel.connect('sqlite://censo.db') # requires sqlite3
if (!DB.table_exists?(:counties))
  DB.create_table :counties do
    Integer :code
    String :name
    Float :population
  end
end


counties = DB[:counties] 
counties.delete
if (counties.count==0)
  csv_text = File.read('db/censo_2019.csv')
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row| 
    if (row["Nível"]=="MU") 
      counties.insert(:code => row["Cód."], 
                      :name=> row["Unidade da Federação"],
                      :population => row["População Residente - 2019"])
    end
  end 
  # Print out the number of records
  puts "Item count: #{counties.count}"
else
  puts "Banco de dados já foi carregado"
end
