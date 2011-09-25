class Vaga
  require '~/projects/arduino/banco.rb'
  require 'rubygems'
  require 'serialport'
  
  
  bd = Banco.new("postgres", "localhost", "projeto_final_development", "postgres", "starfaty")
 
  sp = SerialPort.new("/dev/ttyUSB3", 9600, 8, 1, SerialPort::NONE)
  while true do
    unless sp.gets.nil? || sp.gets == ""
      printf("%s", sp.getc)
    end
  end
end
