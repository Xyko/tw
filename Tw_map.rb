class Tw


	def paintText(x,y,texto,tamanho,fonte,cor)
	  @cr.set_source_color(cor)
	  @cr.select_font_face(fonte, Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_BOLD)
	  @cr.set_font_size(tamanho)
	  @cr.move_to(x,y)
	  @cr.show_text(texto)
	end #PaintText


	def tw_map

    puts "*******************************"
    puts "  Mapping .:                   ".red
    puts "*******************************"

		cream  = Cairo::Color::CREAM
		@A4width  = 595
		@A4height = 842

		@surface = Cairo::ImageSurface.new(@A4width, @A4height)
		@surface.set_fallback_resolution(300.0,300.0)
		@cr = Cairo::Context.new(@surface)
		@cr.set_source_rgba(*cream)
		@cr.paint

		@cr.set_line_width(1)

		x = 10
		y = 10
		texto = 'teste'
		tamanho_texto = 20

		paintText(x,y,texto,tamanho_texto,"Arial",Cairo::Color::BLACK)

		@cr.rectangle(x,y , 100, 100)
		@cr.rectangle(100, 100,200,200)

		@cr.rectangle(x,y,@A4width-20,@A4height-20)
		@cr.stroke
		@cr.target.write_to_png("/Users/francisco/Desktop/mapa_teste.png")
		@cr.stroke

	end

end




