class Vaga
  require '~/projects/arduino/banco.rb'
  require 'rubygems'
  require 'serialport'
  
  
  bd = Banco.new("postgres", "localhost", "projet_final_development", "postgres", "starfaty")
  sp = SerialPort.new("/dev/ttyUSB3", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  
  while true do
    msg = sp.gets
    unless msg.nil?
      cod_arduino = msg.split(":")
      st = db[:status_controlls].filter("cod_arduino = #{cod_arduino[0]}").order(:id).last
      if st[:cod_arduino] !=  RESTRICTED
        puts msg
      end
    end
    sleep(1)
   end
end
