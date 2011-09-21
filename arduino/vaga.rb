class Vaga
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  
  db = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projeto_final_development", :user => "postgres", :password => "starfaty")
  #bd = Banco.new("postgres", "localhost", "projeto_final_development", "postgres", "starfaty")
 
  sp = SerialPort.new("/dev/ttyUSB4", 9600, 8, 1, SerialPort::NONE)

  while true do
    printf("%s", sp.getc)
  end
end
