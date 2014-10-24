class Tw

  def refresh_world 
    
    @redis_ally.flushdb
    @redis_village.flushdb
    @redis_player.flushdb
    @redis_report.flushdb
    @redis_influence.flushdb
    @redis_filters.flushdb

    response    = RestClient.get "http://#{@world}.tribalwars.com.br/map/ally.txt"
    fileAlly    = File.open(@fileAlly_name,"w")
    fileAlly.write CGI::unescape(response.body) 

    response    = RestClient.get "http://#{@world}.tribalwars.com.br/map/village.txt"
    fileVillage = File.open(@fileVillage_name,"w")
    fileVillage.write CGI::unescape(response.body) 

    response    = RestClient.get "http://#{@world}.tribalwars.com.br/map/player.txt"
    filePlayer  = File.open(@filePlayer_name,"w")
    filePlayer.write CGI::unescape(response.body)
    
    File.open(@fileAlly_name   ,"r").each do |line|
      aux = line.split(',')
      @redis_ally.hmset aux[2], 'id', aux[0], 'name', aux[1], 'tag', aux[2], 'members', aux[3], 'villages', aux[4], 'points', aux[5], 'allpoints', aux[6], 'rank', aux[7] 
    end
    puts "Allys     loaded => #{@redis_ally.dbsize} loaded."

    File.open(@fileVillage_name   ,"r").each do |line|
      aux = line.split(',')
      @redis_village.hmset aux[0], 'name', aux[1], 'x', aux[2], 'y', aux[3], 'player', aux[4], 'points', aux[5], 'rank', aux[6] 
    end
    puts "Villages  loaded => #{@redis_village.dbsize} loaded."

    File.open(@filePlayer_name   ,"r").each do |line|
      aux = line.chomp.split(',')
      @redis_player.hmset aux[1], 'id', aux[0], 'name' , aux[1], 'ally', aux[2], 'villages', aux[3], 'points', aux[4], 'rank', aux[5] 
    end
    puts "Players   loaded => #{@redis_player.dbsize}."

    id = 1
    File.open(@fileFilters_name   ,"r").each do |line|
      aux   = line.chomp.split(',')
      if aux.size >= 4
        key   = aux[0]+'_'+id.to_s
        name  = aux[1]
        type  = aux[2]
        value = nil
        case aux[0]
          when 'window'
            @redis_filters.hmset key, 'type', aux[0], 'name', aux[1], 'xi' , aux[2], 'yi' , aux[3], 'xf' , aux[4], 'yf' , aux[5]
          when 'global_conditions'
              case type
                when 's'
                    value = aux[3]
                when 'i'
                    value = aux[3].to_i
                when 'f'
                    value = aux[3].to_f
              end
              @global_conditions[aux[1].to_sym] = value
          else
            puts "Chave não conhecida...."
        end
        id += 1
      end    
    end

    puts "Filters   loaded => #{@redis_filters.dbsize}."
    influence  
    puts "Influence loaded => #{@redis_influence.dbsize}."
    connected?
    report 
    puts "Reports   loaded => #{@redis_report.dbsize}."

  end

end


# 602
# 618
#    524 541

