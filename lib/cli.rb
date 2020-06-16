require 'colorize'
require './db/connect'
class CLI

  def self.run
    CLI.greet

    while true
      # puts "\nmain menu".upcase.magenta
      puts "\nDigite 'help' para ver os comandos disponiveis. Digite 'sair' para sair.".magenta
      print "Digite o comando: ".cyan
      input = gets.chomp

      break if input == "sair" || input == "exit"

      case input
      when "help"
        CLI.help
      when "top 10"
        CLI.list_top
      when "todos"
        CLI.list_counties
      when "busca"
        CLI.codigo
      when "buscauf"
        CLI.codigouf
      when "self help"
        puts "Thank you for taking the time to reflect, and recognizing the importance of self care. <3"
        puts "\n"
        10.times do
          puts "<3".red * 10
        end
      else
        puts "\n  comando inválido, Digite 'help' para ver os comandos disponiveis."
      end
    end
  end

  def self.greet
    puts "Bem vindo ao CLI-CENSO".magenta
  end

  def self.help
    puts "Help".bold
    puts "  help\t\t\t:para mostrar esse menu de ajuda".green
    puts "Listas".bold
    puts "  top.10\t\t:lista os 10 municípios mais populosos".green
    puts "  todos\t\t\t:lista todos os municípios".green
    puts "Data".bold
    puts "  busca\t\t\t:buscar por codigo ou nome do município".green
    puts "  buscauf\t\t\t:buscar por codigo ou nome do estado".green
    puts "Sair".bold
    puts "  sair\t\t\t:sair do programa".green
    puts "  exit\t\t\t:também sai do programa".green
  end

  def self.list_top
    DB['SELECT code, name, population 
        FROM counties
        ORDER BY population DESC
        LIMIT 10'].each do |county|
      puts "Município:"+ "#{county[:name]}".green + 
           " - Populaçao:"+ "#{county[:population]}".green
    end
  end

  def self.submenu_help(menu)
    puts "Help".bold
    puts "  help\t\t\t:mostrar esse menu ajuda(help)".green
    puts "Listar".bold
    puts "  todos\t\t\t:lista tudo #{menu}s".green
    puts "Navegação".bold
    puts "  exit\t\t\t:sair para o menu principal".green
    puts "  menu\t\t\t:mesma coisa que exit".green
  end

  def self.list_counties 
    DB['SELECT code, name, population 
      FROM counties
      ORDER BY population DESC'].each do |county|
    puts "Código: "+ "#{county[:code]}".green + 
         " - Município: "+ "#{county[:name]}".green + 
         " - Populaçao: "+ "#{county[:population]}".green
    end
  end

  def self.list_states 
    DB['SELECT code, name, population 
      FROM states
      ORDER BY code DESC'].each do |state|
    puts "Código: "+ "#{state[:code]}".green + 
         " - Estado: "+ "#{state[:name]}".green
    end
  end

  def self.county_data(counties)
    counties.each do |county|
      puts "Código: "+ "#{county[:code]}".green + 
           " - Município: "+ "#{county[:name]}".green + 
           " - Populaçao: "+ "#{county[:population]}".green
    end
  end

  def self.state_data(counties)
    soma = counties.sum(:population)
    media = counties.avg(:population)
    puts "Soma: "+ "#{soma.round(2)}".green
    puts "Média da população dos municípios: "+ "#{media.round(2)}".green
  end

  def self.codigouf
    loop do
      puts "\nDigite 'listar' para listar todos os estados,
            ou 'sair' para retornar ao menu principal".magenta
      print "Digite um código ou nome do estado: ".cyan

      input = gets.chomp

      break if input == "exit" || input == "menu"

      if input == "todos"
        CLI.list_states
      elsif input == "help"
        CLI.submenu_help("viewer")
      else
        begin
          if input =~ /\d/ 
            id = input.to_i
            state_code = DB['SELECT code FROM states WHERE code = ?', id].get(:code)
            puts state_code
            counties = DB[:counties].where(Sequel.like(:code, "#{state_code}%"))
            raise CLIError if counties.empty?
            CLI.county_data(counties.reverse_order(:population).limit(10))
            CLI.state_data(counties)
            puts "\n"
          else
            name = input
            state_code = DB[:states].where(Sequel.like(:name, "%#{name}%")).get(:code)
            counties = DB[:counties].where(Sequel.like(:code, "#{state_code}%"))
            raise CLIError if counties.empty?
            CLI.county_data(counties.reverse_order(:population).limit(10))
            CLI.state_data(counties)
            puts "\n"
          end
          ## Error handling
          rescue CLIError => error
            puts error.message
          end
      end
    end
  end

  def self.codigo
    loop do
      puts "\nDigite 'listar' para listar todos os municípios,
            ou 'sair' para retornar ao menu principal".magenta
      print "Digite um código ou nome do município: ".cyan

      input = gets.chomp

      break if input == "exit" || input == "menu"

      if input == "todos"
        CLI.list_counties
      elsif input == "help"
        CLI.submenu_help("viewer")
      else
        begin
          if input =~ /\d/ 
            id = input.to_i
            counties = DB['SELECT * FROM counties WHERE code = ?', id]
            raise CLIError if counties.empty?
            CLI.county_data(counties)
            puts "\n"
          else
            name = input
            counties = DB[:counties].where(Sequel.like(:name, "%#{name}%"))
            raise CLIError if counties.empty?
            CLI.county_data(counties)
            puts "\n"
          end
          ## Error handling
          rescue CLIError => error
            puts error.message
          end
      end
    end
  end

  class CLIError < StandardError
    def message
      "\n  entrada inválida, digite 'help' para ver a lista de comandos disponíveis"
    end
  end
end