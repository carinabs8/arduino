class Vaga
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  
  DB = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  #bd = Banco.new("postgres", "localhost", "projeto_final_development", "postgres", "starfaty")
  
  #DB.create_table :arduino_vagas do
  #  primary_key :id
  #  String :name
  #  String :status
  #end
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
