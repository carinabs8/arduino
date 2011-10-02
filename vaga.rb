class Vaga
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  
  db = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  sp = SerialPort.new("/dev/ttyUSB1", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  
  def self.update_status_controll(cod_arduino, db)
    db[:status_controlls].filter(:cod_arduino => cod_arduino, :time_end => nil).update(:time_end => Time.now)
  end
  def self.save_status_controll(status, cod_arduino, db)
    db[:status_controlls].insert(:status => status, :timebegin => Time.now, :cod_arduino => cod_arduino)
  end

  while true do
    msg = sp.gets
    unless msg.nil?
      cod_arduino = msg.split(":")
      st = db[:status_controlls].filter(:cod_arduino => cod_arduino[0]).order(:id).last
      if st.nil?
        save_status_controll(BUSY, cod_arduino[0], db)
      elsif !st.nil?
        if st[:status] !=  RESTRICTED
          if st[:time_end].nil?
            self.update_status_controll(cod_arduino[0], db)
          end
          if !st[:time_end].nil? and st[:status] == BUSY
            save_status_controll(BUSY, cod_arduino[0], db)
          end
        end
      end
    end
    sleep(1)
   end
end
