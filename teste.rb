require 'rubygems'
require 'colorize'

class Teste 

  def initialize(options = {})
    commands
  end

  def metodo1
    puts "Original"
  end

  def commands
    
    require 'prompt'
    extend Prompt::DSL

    desc "Escreve"
    command "escreve" do ||
      metodo1
    end

    desc "Reescreve"
    command "reescreve" do ||
      puts load '/Users/francisco/Dropbox/CRuby/tw/aux.rb'
      metodo1
    end

    Prompt.application.prompt = "Teste > ".blue
    history_file = File.join(File.expand_path(File.dirname(__FILE__) ).to_s, ".history")    
    Prompt::Console.start history_file

  end

 end

 Teste.new 

