class Tw

  def spy_region region

    puts @redis_tregion.dbsize
    puts region
    
  end

  def spys conditions

    puts "spys"
    puts @redis_influence.dbsize
    ap conditions
      
      xi = @global_conditions[:master_x]
      yi = @global_conditions[:master_y]
      distance = @global_conditions[:master_distance].to_f

      @redis_influence.keys.each do |key|
        
        aux = @redis_influence.hmget(key,'x','y','d','p')
        if conditions[:p].split('-').include? aux[3] then
          target = aux[0]+'|'+aux[1]
          page.visit('http://'+@world+'.tribalwars.com.br/game.php?village=14431&screen=place')
          analisaBot
          fill_in('spy'     , :with => '1')
          fill_in('input'   , :with => target)
  page.save_screenshot('spy1.png')
          page.click_button('Ataque')
          analisaBot
          sleep(1)
  page.save_screenshot('spy2.png')
          page.click_button('Enviar ataque')
          analisaBot
          sleep(1)
          puts "ataquei #{target}"
          sleep(1)
        end

      end

  end

end