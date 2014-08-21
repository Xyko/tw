class Tw

  def report conditions={}

    page.visit('http://'+@world+'.tribalwars.com.br/game.php?village=14431repor&mode=attack&screen=report')
    page.save_screenshot('report.png')
    analisaBot
    xi = @global_conditions[:master_x]
    yi = @global_conditions[:master_y]
    distance = @global_conditions[:master_distance].to_f
    if !conditions.empty?
      xi = conditions[:x].to_i if conditions.key?(:x) 
      yi = conditions[:y].to_i if conditions.key?(:y) 
      distance = conditions[:d].to_f if conditions.key?(:d)
    end
    def getall xi, yi
      #puts page.all('a').each.size
      page.all('a').each do |a|
        #puts "aqui #{a.text.include?('xykoBR')} #{a.text.include?('ataca') or a.text.include?('explora')} #{page.has_link?(a.text)} #{a.text}"
        if a.text.include?('xykoBR') and (a.text.include?('ataca') or a.text.include?('explora')) and page.has_link?(a.text) then
         #puts "Analazing #{a.text}...."
          xf    = a.text.scan(/[[:digit:]]{3}\|[[:digit:]]{3}/)[0].to_s.split('|')[0].to_i
          yf    = a.text.scan(/[[:digit:]]{3}\|[[:digit:]]{3}/)[0].to_s.split('|')[1].to_i
          dist  = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)            
          @redis_report.hmset xf.to_s+'_'+yf.to_s,  'link' , 'http://'+@world+'.tribalwars.com.br'+a[:href].to_s, 'x' ,xf , 'y',  yf, 'd', dist
        end
      end
    end
    getall xi, yi
    [2,3,4].each do |index|
      if !page.all('a', :text => "[#{index}]").empty?()
        click_link("[#{index}]")
        getall xi, yi
      end
    end
    #puts reports # 0800 880 0888
  end

end