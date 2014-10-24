class Tw

	def get_region candidate
		@redis_filters.keys.each do |key|
			region = nil
      region = @redis_filters.hgetall(key) 
      return region if region['name'] == candidate
		end
		return nil
	end

	def show_regions
		@redis_filters.keys.each do |key|
			@filter = @redis_filters.hgetall(key) 
			puts @filter['name']
		end
	end

	def nears x,y
		# @global_conditions[:villages_info].each do |key,value|
		# 	ap key
		# end
		puts @global_conditions[:villages_info].size
	end

	def windows region
		i = 0
		xi = region['xi'].to_i
		xf = region['xf'].to_i
		yi = region['yi'].to_i
		yf = region['yf'].to_i
  	@redis_influence.keys.each do |key|
    	aux = @redis_influence.hmget(key,'x','y','d','p')
    	x = aux[0].to_i
    	y = aux[1].to_i   
    	#puts "#{x} #{y} #{xi} #{yi} #{xf} #{yf} #{x.between?( xi, xf)}" 	
    	#puts "#{x} #{y} #{xi} #{yi} #{xf} #{yf} #{y.between?( yi, yf)}" 	
    	#puts "#{x} #{y} #{xi} #{yi} #{xf} #{yf} #{x.between?( xi, xf) && y.between?( yi, yf)}" 	
    	if x.between?( xi, xf) && y.between?( yi, yf) && aux[3] == '0' then 
    		@redis_tregion.hmset aux[0]+"_"+aux[1], 'x',x,'y',y
    		i += 1
    		puts aux[0]+"_"+aux[1]
    	end
    end
    puts "#{region['name']}  #{i} #{@redis_tregion.dbsize}"
	end

	def show
		@redis_filters.keys.each do |key|
		      filter = @redis_filters.hgetall(key) 
		      ap filter
		    end
				puts "Filters.: #{@redis_filters.dbsize}"
				puts "TRegion.: #{@redis_tregion.dbsize}"
	end


	def set
				show_regions
		   	puts "region.: #{region = gets.strip}"
		    windows (get_region region)
				# windows (get_region 'east')
				# windows (get_region 'south')
				# windows (get_region 'north')
				# windows (get_region 'all')
				# windows (get_region 'west')
				# windows (get_region 'center')
	end

	def reload_filters
		 		@redis_tregion.flushdb
	  		@redis_filters.flushdb
  		 	id = 1
		    File.open(@fileFilters_name   ,"r").each do |line|
		    	
		    	if !line.start_with?('#')
			      aux   = line.chomp.split(',')
			      if aux.size >= 4
			        key   = aux[0]+'_'+id.to_s
			        name  = aux[1]
			        type  = aux[2]
			        value = nil
			        case aux[0]
			          when 'window'
			            @redis_filters.hmset key, 'type', aux[0] ,'name', aux[1], 'xi' , aux[2], 'yi' , aux[3], 'xf' , aux[4], 'yf' , aux[5]
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
		    end
		    puts "Filters   loaded => #{@redis_filters.dbsize}." 
		    ap @global_conditions
	end

  def region_conditions conditions
  	case conditions
	  	when 'show'
	  		show
	  	when 'get'
	  	when 'set'
	  		set
	  	when 'clean'
	  		@redis_tregion.flushdb
	  	when 'reload'
	  		reload_filters
	  end
  end

end