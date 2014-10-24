class Tw


  def getall_reports xi, yi
    page.all('a').each do |a|
      if a.text.include?('xykoBR') and (a.text.include?('ataca') or a.text.include?('explora')) and page.has_link?(a.text) then
        xf    = a.text.scan(/[[:digit:]]{3}\|[[:digit:]]{3}/)[0].to_s.split('|')[0].to_i
        yf    = a.text.scan(/[[:digit:]]{3}\|[[:digit:]]{3}/)[0].to_s.split('|')[1].to_i
        dist  = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)            
        @redis_report.hmset xf.to_s+'_'+yf.to_s,  'link' , 'http://'+@world+'.tribalwars.com.br'+a[:href].to_s, 'x' ,xf , 'y',  yf, 'd', dist
      end
    end
  end

  def get_report report_page
    puts 
    page.visit(report_page)
    page.save_screenshot('report.png')
    analisaBot
    xi = @global_conditions[:master_x]
    yi = @global_conditions[:master_y]
    distance = @global_conditions[:master_distance].to_f
    getall_reports xi, yi
    [2,3,4].each do |index|
      if !page.all('a', :text => "[#{index}]").empty?()
        click_link("[#{index}]")
        getall_reports xi, yi
      end
    end
  end

  def report 
    @redis_report.flushdb
    get_report 'http://'+@world+'.tribalwars.com.br/game.php?village=14431&mode=attack&group_id=0&screen=report'
    get_report 'http://'+@world+'.tribalwars.com.br/game.php?village=14431&mode=attack&group_id=16089&screen=report'
  end

  def clean_report
    count  = 0
    puts "Atualizando reports....".green
    report  
    puts "Analizando #{@redis_report.dbsize} relatórios........".green
    @redis_report.keys('*').each do |key|
      count += 1
      report = @redis_report.hmget(key,'link','x','y','dist') 
      visit(report[0])
      analisaBot
      table = page.find_by_id('attack_spy_resources').text.gsub(/[a-zA-Z:çá()éí.]/,'')
      wood  = table.split[0].to_i
      stone = table.split[1].to_i
      iron  = table.split[2].to_i
      capacity = wood + stone + iron
      if capacity <= 30
        puts format("%s %i/%i %s",key,count,@redis_report.dbsize, "Clean...".red)
        all('a').select {|elt| elt.text == "Apagar" }.first.click
      else
        puts format("%s %i/%i %s",key,count,@redis_report.dbsize, "Ok...".blue)
      end
    end
  end


end



