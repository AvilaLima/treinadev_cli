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
      when "listar top 10"
        CLI.list_top
      when "busca por município(nome)"
        CLI.list_viewers
      when "busca por código"
        CLI.list_countries
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
    puts "List".bold
    puts "  list top 10\t\t:list os 10 municípios mais populosos".green
    puts "  list viewers\t\t:list names of all viewers".green
    puts "  list countries\t:list names of all countries between shows/viewers".green
    puts "Data".bold
    puts "  codigo\t\t\t:buscar por codigo".green
    puts "  nome\t\t:buscar por nome".green
    puts "Quit".bold
    puts "  quit\t\t\t:sair do programa".green
    puts "  exit\t\t\t:também sai do programa".green
  end

  def self.list_top
    Show.all.each_with_index { |show,i| puts (i+1).to_s.bold + ".\t#{show.title}" }
  end

  def self.list_viewers
    Viewer.all.each_with_index { |viewer,i| puts (i+1).to_s.bold + ".\t#{viewer.name}" }
  end

  def self.submenu_help(menu)
    puts "Help".bold
    puts "  help\t\t\t:show this help menu".green
    puts "List".bold
    puts "  list\t\t\t:list all #{menu}s".green
    puts "Navigation".bold
    puts "  exit\t\t\t:exit to main menu".green
    puts "  main\t\t\t:alias for exit".green
  end

  def self.list_countries
    Show.countries.each { |country| puts country }
  end

  def self.show_data(show)
    puts "  title:\t\t#{show.title}"
    puts "  network:\t\t#{show.network}"
    puts "  country:\t\t#{show.country}"
    puts "  total viewers:\t#{show.num_ratings}"
    puts "  average rating:\t#{show.average_rating}"
  end

  def self.list_summary?(show)
    loop do
      print "List summary for this show? (y/n): ".magenta
      yn = gets.chomp

      case yn
      when 'y'
        puts show.summary
        break
      when 'n'
        break
      end
    end
  end

  def self.list_viewers_of_show?(show)
    loop do
      print "List viewers for this show? (y/n): ".magenta
      yn = gets.chomp

      case yn
      when 'y'
        loop do
          print "List all viewers, in same country, or living elsewhere? (all/same/other): ".magenta

          which_viewers = gets.chomp

          case which_viewers
          when "same"
            # show.viewers.select { |v| v.country == show.country }.each { |v| puts v.name }
            show.viewers.where("country = ?", show.country).each { |v| puts v.name }
            break
          when "other"
            # show.viewers.reject { |v| v.country == show.country }.each { |v| puts v.name + ",  " + v.country.yellow }
            show.viewers.where("country != ?", show.country).each { |v| puts v.name + ",  " + v.country.yellow }
            break
          when "all"
            show.viewers.each { |v| puts v.name + ",  " + v.country.yellow }
            break
          end
        end
        puts "\n"
      when 'n'
        break
      end
    end
  end

  def self.viewer_data(viewer)
    puts "  name:\t\t#{viewer.name}"
    puts "  country:\t#{viewer.country}"
    puts "  top shows:"
    if viewer.top_three.empty?
      puts "\tno shows rated".upcase.magenta
    else
      puts "\trating\tshow".upcase.magenta
      viewer.top_three.each { |r| puts "\t#{r.rating}\t#{r.show.title}" }
    end
  end

  def self.list_watched_shows?(viewer)
    loop do
      print "List all watched shows? (y/n): ".magenta
      yn = gets.chomp

      case yn
      when 'y'
        viewer.shows.each { |s| puts s.title }
        break
      when 'n'
        break
      end
    end
  end

  def self.list_favorite_shows?(viewer)
    loop do
      print "List data for favorite shows? (y/n): ".magenta
      yn = gets.chomp

      case yn
      when 'y'
        loop do
          print "Which show? (1,2,3): ".magenta
          show_num = gets.chomp.to_i

          if show_num <=3 && show_num > 0
            show = viewer.top_three[show_num-1].show
            CLI.show_data(show)
            CLI.list_summary?(show)
            puts "\n"
            break
          end
        end
      when 'n'
        break
      end
    end
  end

  def self.show
    loop do
      puts "\nType 'list' to list all shows, or 'exit' to return to main menu".magenta
      print "Enter show ID: ".cyan

      input = gets.chomp

      break if input == "exit" || input == "main"

      if input == "list"
        CLI.list_shows
      elsif input == "help"
        CLI.submenu_help("show")
      else
        begin
          id = input.to_i

          ## FIXME: This will also handle cases where input is not an integer
          ## WHY?
          raise CLIError if id > Show.count || id < 1
          show = Show.all[id-1]
          CLI.show_data(show)
          puts "\n"
          CLI.list_summary?(show)
          CLI.list_viewers_of_show?(show)
        ## Do some error handling
        rescue CLIError => error
          puts error.message
        end
      end
    end
  end

  def self.viewer
    loop do
      puts "\nType 'list' to list all viewers, or 'exit' to return to main menu".magenta
      print "Enter viewer ID: ".cyan

      input = gets.chomp

      break if input == "exit" || input == "main"

      if input == "list"
        CLI.list_viewers
      elsif input == "help"
        CLI.submenu_help("viewer")
      else
        begin
          id = input.to_i
          ## FIXME: This is hacky but works
          raise CLIError if id > Viewer.count || id < 1
          viewer = Viewer.all[id-1]
          CLI.viewer_data(viewer)
          puts "\n"
          CLI.list_watched_shows?(viewer)
          CLI.list_favorite_shows?(viewer)
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