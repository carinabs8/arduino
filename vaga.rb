class Vaga
  require '~/projects/arduino/banco.rb'
  require 'rubygems'
  require 'serialport'
  
  
  bd = Banco.new("postgres", "localhost", "projeto_final_development", "postgres", "starfaty")
 
  sp = SerialPort.new("/dev/ttyUSB3", 9600, 8, 1, SerialPort::NONE)
i = 0
  while true do
    printf("%s", sp.getc)
    unless sp.getc.nil? || sp.getc == ""
      printf("Estaos ai %i", i)
      i= i + 1
    end
  end
end
