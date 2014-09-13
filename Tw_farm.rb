class Tw 
 
  def farmall

      count      = 0
      farm_total = 0
      puts "Atualizando reports....".green
      report
      puts "Analizando #{@redis_report.dbsize} relatórios........".green
      farm_total = 0
      @redis_report.keys('*').each do |key|
        xi =   key.split('_')[0].to_i
        yi =   key.split('_')[1].to_i
        count += 1
        puts format("%s %i/%i %i %i",key,count,@redis_report.dbsize, xi, yi)
        refresh_my_villes
        attack_vector = near_to xi, yi 
        selected = 0
        attack_vector.sort_by {|k,v| v[:distance]}.each do |key_ville,value_ville|

          if value_ville[:farm_capacity] > 0
            selected = key_ville
            break
          end  
          
        end

        if selected != 0

          report = @redis_report.hmget(key,'link','x','y','dist') 
          report[0].gsub!('14431',selected)
          farm_total += farm_from report, selected
        
        else

          puts "Farmers depleted... waiting for good news times...".green   
          break  

        end

        puts "*******************************"
        puts "  FarmTotal .: #{farm_total} ".red
        puts "*******************************"

        # Sleep random for anti-BOT
        r = rand(10)
        puts "Sleeping #{r} seconds...".green
        sleep r

      end

  end

  def farm_from report, selected
    begin

      visit(report[0])
      save_screenshot('farm_report.png', :full => true)
      analisaBot

      table = page.find_by_id('attack_spy_resources').text.gsub(/[a-zA-Z:çá()éí.]/,'')

      wood  = table.split[0].to_i
      stone = table.split[1].to_i
      iron  = table.split[2].to_i
      capacity = wood + stone + iron
      tableDefesa = page.find_by_id('attack_info_def').text

      defensor = tableDefesa.split(':')[1].gsub('Defensor','').gsub('Destino','').strip
      alvo     = tableDefesa.split(':')[2].gsub('Quantidade','').strip
      tropas = 0
      tableDefesa.split(':')[3].gsub('Perdas','').strip.split(' ').each do |tropa|
        tropas += tropa.to_i
      end

      puts "Capacity #{capacity.to_s.green}".blue
      puts "Defenser #{defensor.to_s.green}".blue
      puts "Target   #{alvo.to_s.green}".blue
      puts "Troops   #{tropas.to_s.green}".blue
      show_villes selected

      if capacity <= 30
        puts "Clean empty page...".red
        all('a').select {|elt| elt.text == "Apagar" }.first.click
        return 0
      else

        if tropas > 0
          puts "Troops found. Clean page......".red
          all('a').select {|elt| elt.text == "Apagar" }.first.click if defensor == '---'
          return 0
        else

          # # Attack with ideal confitions... I will continue ....  
          c_button = '/html/body/table/tbody/tr[2]/td[2]/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td[2]/table/tbody/tr/td/table[2]/tbody/tr[3]/td/table[3]/tbody/tr[2]/td/span/span/span[3]/span/span[3]/span/a[3]'
          #puts "CButton = #{page.find(:xpath, c_button)}"
          button = page.find(:xpath, c_button)
          button.trigger('click')
          all('a').select {|elt| elt.text == "Apagar" }.first.trigger('click')
          return capacity

        end 
      end

    rescue Capybara::ElementNotFound
      puts "Pagina com erro. Retornando....".red
      return 0
    end
  end


  def farm conditions

      def get_my_village_id ville 
        return '14431' if ville == 'xykoBR000' 
        return '13854' if ville == 'xykoBR001' 
        return '13686' if ville == 'xykoBR002' 
        return '12748' if ville == 'xykoBR003' 
        return '14431'
      end

      count      = 0
      farm_total = 0

      puts "Atualizando reports...."
      report
      puts "Analizando #{@redis_report.dbsize} relatórios........"
      @redis_report.keys('*').each do |key|
        report = @redis_report.hmget(key,'link','x','y','dist') #.to_s.gsub('VILLAGEID',get_my_village_id(conditions[:a])) 

        report[0].gsub!('14431',get_my_village_id(conditions[:a]))

        #puts report.inspect 

        begin
          number = 10
          number = conditions[:n].to_i if conditions[:n].to_i >= 2
          count += 1
          break if count > number

          visit(report[0])
          save_screenshot('farm_report.png', :full => true)
          analisaBot

          table = page.find_by_id('attack_spy_resources').text.gsub(/[a-zA-Z:çá()éí.]/,'')

          wood  = table.split[0].to_i
          stone = table.split[1].to_i
          iron  = table.split[2].to_i
          capacity = wood + stone + iron
          tableDefesa = page.find_by_id('attack_info_def').text

          defensor = tableDefesa.split(':')[1].gsub('Defensor','').gsub('Destino','').strip
          alvo     = tableDefesa.split(':')[2].gsub('Quantidade','').strip
          tropas = 0
          tableDefesa.split(':')[3].gsub('Perdas','').strip.split(' ').each do |tropa|
            tropas += tropa.to_i
          end

          puts ""
          puts "Report n. #{count}"
          puts "Capacity #{capacity}"
          puts "Defensor #{defensor}"
          puts "Alvo     #{alvo}"
          puts "Tropas   #{tropas}"

          if capacity <= 30
            puts "Apagando página (quaze) zerada...".red
            all('a').select {|elt| elt.text == "Apagar" }.first.click
          else

            if tropas > 0
              puts "Apagando página com tropas...".red
              all('a').select {|elt| elt.text == "Apagar" }.first.click if defensor == '---'
            else

              # # Attack with ideal confitions... I will continue ....  
              c_button = '/html/body/table/tbody/tr[2]/td[2]/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td[2]/table/tbody/tr/td/table[2]/tbody/tr[3]/td/table[3]/tbody/tr[2]/td/span/span/span[3]/span/span[3]/span/a[3]'
              puts "CButton = #{page.find(:xpath, c_button)}"
              button = page.find(:xpath, c_button)
              button.trigger('click')
              farm_total += capacity
              all('a').select {|elt| elt.text == "Apagar" }.first.trigger('click')


#<a class="farm_tooltip farm_village_14008 farm_icon farm_icon_c" onclick="return Accountmanager.farm.sendUnitsFromReport(this, 14008, 13984777)" data-units="{&quot;spear&quot;:0,&quot;sword&quot;:0,&quot;axe&quot;:0,&quot;archer&quot;:0,&quot;spy&quot;:1,&quot;light&quot;:21,&quot;marcher&quot;:0,&quot;heavy&quot;:0,&quot;ram&quot;:0,&quot;catapult&quot;:0,&quot;knight&quot;:0,&quot;snob&quot;:0,&quot;militia&quot;:0}" style="float:left;margin:5px" href="#"></a>
#html.js.history.draganddrop.borderimage.textshadow.cssanimations.localstorage.sessionstorage.filereader.json.performance body#ds_body table#main_layout tbody tr.shadedBG td.maincell table#contentContainer tbody tr td table.content-border tbody tr td#inner-border table.main tbody tr td#content_value table.no_spacing tbody tr td table.vis tbody tr td.nopad table.vis tbody tr td table#attack_spy_resources tbody tr td span.res-icons-separated span.nowrap span span.nowrap span span.nowrap a.farm_tooltip.farm_village_14008.farm_icon.farm_icon_c            


            end 
          end

          # Sleep random for anti-BOT
          r = rand(10)
          puts "Sleeping #{r} segundos..."
          sleep r

        rescue Capybara::ElementNotFound
          puts "Pagina com erro. Retornando...."
        end

        puts "*******************************"
        puts "  FarmTotal .: #{farm_total} ".red
        puts "*******************************"

      end

      refresh_my_villes

  end

end