module DependenceProvider
  require 'sequel'
  require 'serialport'
  
  def connection
    @db = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  end
  
  def serial_port
    SerialPort.new("/dev/ttyUSB4", 9600, 8, 1, SerialPort::NONE)
  end
end