class Vaga
  require '~/projects/arduino/banco.rb'
  require 'rubygems'
  require 'serialport'
  
  
  bd = Banco.new("postgres", "localhost", "projet_final_development", "postgres", "starfaty")
  sp = SerialPort.new("/dev/ttyUSB0", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  while true do
	msg = sp.gets
    unless msg.nil?
      puts msg
    end
    sleep(1)
   end
end
