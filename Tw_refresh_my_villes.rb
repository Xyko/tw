class Tw

  def refresh_my_villes
    connected?
    #page.visit('http://'+@world+'.tribalwars.com.br/game.php?village='+@global_conditions[:master_id]+'&mode=combined&screen=overview_villages')
    page.visit('http://'+@world+'.tribalwars.com.br/game.php?village='+@global_conditions[:master_id]+'&mode=units&screen=overview_villages&type=there ')

    table = page.find_by_id('units_table')
    table.all('tr').each  do |tr|

      if tr.text.include? 'suas próprias'
        
        ville_name  = tr.text.split(')')[0].split('(')[0].strip
        ville_xy    = (tr.text.match /\d{3}\|\d{3}/).to_s 
        ville_x     = ville_xy.split('|')[0]
        ville_y     = ville_xy.split('|')[1]
        tropas      = tr.text.split('suas próprias')[1].gsub('Comandos','').strip.split(' ')
        spear   = tropas[0]
        sword   = tropas[1]
        axe     = tropas[2]
        spy     = tropas[4]
        ligth   = tropas[5]
        heavy   = tropas[7]      
        ram     = tropas[8]      
        catapult= tropas[9]      
        knight  = tropas[10]      
        snob    = tropas[11]      
        @redis_myvilles.hmset ville_xy, 'name', ville_name, 'x', ville_x, 'y' , ville_y, 'spear',spear     ,'sword',sword     ,'axe',axe       ,'spy',spy       ,'ligth',ligth     ,'heavy',heavy     ,'ram',ram       ,'catapult',catapult  ,'knight',knight    ,'snob',snob      
        puts ""
        puts "Ville.:   #{ville_name}"
        puts "spear     => #{spear}"
        puts "axe       => #{axe}"
        puts "spy       => #{spy}"
        puts "ligth     => #{ligth}"
        puts "heavy     => #{heavy}"
        puts "ram       => #{ram}"
        puts "catapult  => #{catapult}"
        puts "knight    => #{knight}"
        puts "snob      => #{snob}"

      end

    end 

  end

end