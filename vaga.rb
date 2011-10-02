class Vaga
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  
  bd = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  sp = SerialPort.new("/dev/ttyUSB0", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  
  while true do
    msg = sp.gets
    unless msg.nil?
      cod_arduino = msg.split(":")
      st = bd[:status_controlls].filter("cod_arduino = '#{cod_arduino[0]}'").order(:id).last
      if st[:cod_arduino] !=  RESTRICTED
        puts msg
      end
    end
    sleep(1)
   end
end
