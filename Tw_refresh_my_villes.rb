class Tw

  def show_villes highlight=nil
    puts format("%-20s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s",
        "Ville","Id","spear","sword","axe","spy","light","heavy","ram","catapult","knight","snob","CFarm","Dist.")
    @global_conditions[:villages_info].each do |key,ville|
        if highlight == key
        puts format("%-20s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s",ville[:name],key,
        ville[:spear   ],
        ville[:sword   ],
        ville[:axe     ],
        ville[:spy     ],
        ville[:light   ],
        ville[:heavy   ],
        ville[:ram     ],
        ville[:catapult],
        ville[:knight  ],
        ville[:snob    ],
        ville[:farm_capacity],
        ville[:distance]).red
        else
        puts format("%-20s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s",ville[:name],key,
        ville[:spear   ],
        ville[:sword   ],
        ville[:axe     ],
        ville[:spy     ],
        ville[:light   ],
        ville[:heavy   ],
        ville[:ram     ],
        ville[:catapult],
        ville[:knight  ],
        ville[:snob    ],
        ville[:farm_capacity],
        ville[:distance]).blue
        end
    end
  end 


  def refresh_my_villes 
    connected?
    
    page.visit('http://br62.tribalwars.com.br/game.php?village='+@global_conditions[:master_id]+'&mode=combined&screen=overview_villages')
    analisaBot

    table = page.find_by_id('combined_table')
    table.all('tr').each  do |tr|

        if tr.text.size > 10

            ville_name  = tr.text.split(')')[0].split('(')[0].strip
            ville_xy    = (tr.text.match /\d{3}\|\d{3}/).to_s 
            ville_x     = ville_xy.split('|')[0]
            ville_y     = ville_xy.split('|')[1]
            tropas      = tr.text.split(' ')
            spear   = tropas[5]
            sword   = tropas[6]
            axe     = tropas[7]
            spy     = tropas[9]
            light   = tropas[10]
            heavy   = tropas[12]      
            ram     = tropas[13]      
            catapult= tropas[14]      
            knight  = tropas[15]      
            snob    = tropas[16]      

            @global_conditions[:villages_info].each do |key,ville|
                if  ville[:name] == ville_name
                    ville[:spear   ] = spear    
                    ville[:sword   ] = sword    
                    ville[:axe     ] = axe      
                    ville[:spy     ] = spy      
                    ville[:light   ] = light    
                    ville[:heavy   ] = heavy          
                    ville[:ram     ] = ram            
                    ville[:catapult] = catapult       
                    ville[:knight  ] = knight         
                    ville[:snob    ] = snob   
                    ville[:farm_capacity] =  spear.to_i * 25 + sword.to_i * 15 + axe.to_i * 10 + light.to_i * 80 + heavy.to_i * 50 
                end
            end
        
        end

    end 

  end

end