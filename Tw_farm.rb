class Tw 
 
  def farm conditions

      def get_my_village_id ville 
        return '14431' if ville == 'xykoBR000' 
        return '13854' if ville == 'xykoBR001' 
        return '13686' if ville == 'xykoBR002' 
        return '12748' if ville == 'xykoBR003' 
        return '14431'
      end

      count = 0
      farm_total = 0

      puts "Atualizando reports...."
      report
      puts "Analizando #{@redis_report.dbsize} relatórios........"
      @redis_report.keys('*').each do |key|
        report = @redis_report.hmget(key,'link','x','y','dist') #.to_s.gsub('VILLAGEID',get_my_village_id(conditions[:a])) 

        report[0].gsub!('14431',get_my_village_id(conditions[:a]))

        puts report.inspect 

        begin
          number = 10
          number = conditions[:n].to_i if conditions[:n].to_i >= 2
          count += 1
          break if count > number
  puts "1"
          visit(report[0])
          save_screenshot('farm_report.png', :full => true)
          analisaBot
  puts "2"
          table = page.find_by_id('attack_spy_resources').text.gsub(/[a-zA-Z:çá()éí.]/,'')
  puts "3"
          wood  = table.split[0].to_i
          stone = table.split[1].to_i
          iron  = table.split[2].to_i
          capacity = wood + stone + iron
          tableDefesa = page.find_by_id('attack_info_def').text
  puts "4"
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
              c_button = '/html/body/table/tbody/tr[2]/td[2]/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td[2]/table/tbody/tr/td/table[2]/tbody/tr[3]/td/table[3]/tbody/tr[2]/td/a[3]'
              puts "CButton = #{page.find(:xpath, c_button)}"
              button = page.find(:xpath, c_button)
              button.trigger('click')
              farm_total += capacity
              all('a').select {|elt| elt.text == "Apagar" }.first.trigger('click')
            
            end 
          end

          # Sleep random for anti-BOT
          r = rand(10)
          puts "Sleeping #{r} segundos..."
          sleep r

        rescue Capybara::ElementNotFound
          puts "Pagina com erro. movendo...."
          all('a').select {|elt| elt.text == "Mover" }.first.click
          save_screenshot('farm_report.png', :full => true)

        end

# 27.40 27.15
# 13.71 13.71
# 41.11

        puts "*******************************"
        puts "  FarmTotal .: #{farm_total} ".red
        puts "*******************************"

      end

      refresh_my_villes

  end

end