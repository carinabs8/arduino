class Vaga
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  
  @db = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  sp = SerialPort.new("/dev/ttyUSB3", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  
  def self.exist_vaga?(cod_arduino)
    vaga            = @db[:vagas].filter(:cod_arduino => cod_arduino).order(:id).last
    return true if !vaga.nil?
  end
  def self.update_status_controll(cod_arduino)
    if exist_vaga?(cod_arduino)
      @db[:status_controlls].filter(:cod_arduino => cod_arduino, :time_end => nil).update(:time_end => Time.now)
      save_vaga_status(cod_arduino, AVAILABLE)
    end
  end
  
  def self.save_status_controll(cod_arduino)
    if exist_vaga?(cod_arduino)
      @db[:status_controlls].insert(:timebegin => Time.now, :cod_arduino => cod_arduino)
      save_vaga_status(cod_arduino, BUSY)
    end
  end
  
  def self.save_vaga_status(cod_arduino, status)
    vaga            = @db[:vagas].filter(:cod_arduino => cod_arduino).order(:id).last
    status_controll = @db[:status_controlls].filter(:cod_arduino => cod_arduino).order(:id).last
    
    @db[:vaga_status].insert(:vaga_id => vaga[:id], :status_controll_id => status_controll[:id], :status => status)
  end
  while true do
    msg = sp.gets
    unless msg.nil?
      cod_arduino = msg.split(":")
      st = @db[:status_controlls].filter(:cod_arduino => cod_arduino[0]).order(:id).last
      if st.nil?
        save_status_controll(cod_arduino[0])
      elsif !st.nil?
        if st[:status] !=  RESTRICTED
          if st[:time_end].nil?
            self.update_status_controll(cod_arduino[0])
            if cod_arduino[1] == BUSY
              save_status_controll(cod_arduino[0])
            end
          end

          if !st[:time_end].nil? and cod_arduino[1] == BUSY
            save_status_controll(cod_arduino[0])
          end
        end
      end
    end
    sleep(1)
   end
end
