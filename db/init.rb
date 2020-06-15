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
if (!DB.table_exists?(:states))
  DB.create_table :states do
    Integer :code
    String :name
    Float :population
  end
end

counties = DB[:counties] 
states = DB[:states]  
if (counties.count==0) && (states.count==0)
  csv_text = File.read('db/censo_2019.csv')
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row| 
    if (row["Nível"]=="MU") 
      counties.insert(:code => row["Cód."], 
                      :name=> row["Unidade da Federação"],
                      :population => row["População Residente - 2019"])
    else
      states.insert(:code => row["Cód."], 
        :name=> row["Unidade da Federação"],
        :population => row["População Residente - 2019"])
    end
  end 
  # Print out the number of records
  puts "Estados inseridos: #{states.count}"
  puts "Municípios inseridos: #{counties.count}"
else
  puts "Banco de dados já foi carregado"
end
