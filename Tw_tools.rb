class Tw

  def clear
    %x(clear)
  end

  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def analisaBot
    botMsg = "contra Bots"
    if page.body.to_s.index(botMsg)
      puts "BOT found.... aborting..."
      page.save_screenshot('boot.png')
      exit(0)
    end
  end

  def login  
    visit('/')
    fill_in('user',     :with => @login)
    fill_in('password', :with => @passwd)
    page.find(:xpath,'/html/body/div[2]/div[1]/div[2]/div/div[2]/div[2]/form/div/div/div/a').click
    page.save_screenshot('login1.png')
    analisaBot
    page.find(:xpath,'/html/body/div[2]/div[1]/div[2]/div/div[2]/div[2]/div[1]/div[2]/form/div[1]/div/a[1]').click
    analisaBot
    page.save_screenshot('login2.png')
    @connected = true

    puts  Capybara.current_session.driver.headers.inspect

    player = @redis_player.hmget(@login,'id','name','ally','villages','points')

    @global_conditions[:player_info] = {:player => @login,
                                        :id     => player[0],
                                        :name   => player[1],
                                        :ally   => player[2],
                                        :villages => player[3],
                                        :points   => player[4]
                                      }

    @redis_village.keys('*').each do |key|
      ville = @redis_village.hmget(key,'name','x','y','player')
      if ville[3] == @global_conditions[:player_info][:id]
        aux = {key => {:name => ville[0], :x => ville[1], :y => ville[2],
            :spear   => 0,
            :sword   => 0,
            :axe     => 0,
            :spy     => 0,
            :light   => 0,
            :heavy   => 0,      
            :ram     => 0,      
            :catapult=> 0,      
            :knight  => 0,      
            :snob    => 0,
            :farm_capacity => 0,
            :distance => 0} 
        }
        @global_conditions[:villages_info].merge!(aux)
      end
    end

    puts "Connected status.: ON".blue

  end

  def influence  conditions={} 
    xi = @global_conditions[:master_x]
    yi = @global_conditions[:master_y]
    distance = @global_conditions[:master_distance].to_f
    if !conditions.empty?
      xi = conditions[:x].to_i if conditions.key?(:x) 
      yi = conditions[:y].to_i if conditions.key?(:y) 
      distance = conditions[:d].to_f if conditions.key?(:d)
    end
    @redis_village.keys('*').each do |key|
      ville = @redis_village.hmget(key,'name','x','y','player','points')
      xf = ville[1].to_i
      yf = ville[2].to_i
      dist = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
      if dist <= distance and dist > 0 
        @redis_influence.hmset key , 'x' , xf, 'y' , yf, 'd' , dist , 'p' , ville[3] 
      end
    end
  end

  def yesno(prompt = 'Continue?', default = true)
    a = ''
    s = default ? '[Y/n]' : '[y/N]'
    d = default ? 'y' : 'n'
    until %w[y n].include? a
    a = ask("#{prompt} #{s} ") { |q| q.limit = 1; q.case = :downcase }
    a = d if a.length == 0
    end
    a == 'y'
  end

  def connected?
    if !@connected
        login
        Prompt.application.prompt = "Tribal > ".blue
    end
  end

  # def show_notes
  #   connected?
  #   page.visit('http://'+@world+'.tribalwars.com.br/game.php?village='+@global_conditions[:master_id]+'&screen=overview')
  #   analisaBot
  #   page.save_screenshot('overview.png')
  #   x = page.all('a').select {|elt| elt.text == "» Editar" }.first.click
  #   puts x.inspect
  #   page.save_screenshot('notes.png')
  # end

  def show_conditions conditions
    ap @global_conditions
    ap conditions
  end

  def to_hash_conditions conditions
      hash = Hash.new
      conditions.split.each do |condition|
        key   = condition.split(',')[0].to_sym
        value = condition.split(',')[1]
        hash.merge!({key => value}) 
      end
      return hash
  end

  def near_to(xi, yi)
     result = Hash.new
     @global_conditions[:villages_info].each do |key,ville|
        xf = ville[:x].to_i
        yf = ville[:y].to_i
        distance = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
        ville[:distance] = distance
        result.merge!({key => {:distance => distance, :farm_capacity => ville[:farm_capacity]}})
     end
     return result
  end


  def get_player player

    return @redis_player.hmget("#{player}",'id','name','ally','villages','points')

    # ally = info[2]
    # id   = info[0]
    # puts info.inspect
    # puts ally
    # keys = @redis_village.keys
    # keys.sort.each do |key|
    #   if @redis_village.hmget(key,'player')[0] == id
    #     aux = @redis_village.hmget(key,'name','x','y')
    #     puts "#{key} #{aux.inspect}"
    #   end
    # end
    # keys = @redis_player.keys
    # keys.sort.each do |key|
    #   if @redis_player.hmget(key,'ally')[0] == ally
    #     aux = @redis_player.hmget(key,'id','name','ally','villages','points')
    #     puts aux.inspect
    #   end
    # end

  end

  # def method_missing(method, *args, &block)
  #   puts method
  #   puts args
  #   puts block
  # end

end