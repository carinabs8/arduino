class Vacancy
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  
  @db = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  sp = SerialPort.new("/dev/ttyUSB0", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  
  def self.exist_vacancy?(cod_arduino)
    vacancy = @db[:vacancies].filter(:cod_arduino => cod_arduino).order(:id).last
    return true if vacancy
  end
  def self.get_status(cod_arduino)
    vacancy = @db[:vacancies].filter(:cod_arduino => cod_arduino).order(:id).last
    
  end
  
  def self.update_status_controll(cod_arduino)
    if exist_vacancy?(cod_arduino)
      vacancy = get_status(cod_arduino)
      vacancy[:status].update(:status => AVAILABLE)
      old_status = vacancy[:old_status]
      
      @db[:status_controlls].filter(:vacancy_id => vacancy[:id], :time_end => nil).update(:time_end => Time.now, :current_status => AVAILABLE, :old_status => old_status)
    end
  end

  def self.save_status_controll(cod_arduino)
    if exist_vacancy?(cod_arduino)
      vacancy = get_status(cod_arduino)
      vacancy[:status].update(:status => AVAILABLE)
      @db[:status_controlls].insert(:vacancy_id => vacancy[:id], :timebegin => Time.now, :current_status => BUSY)
    end
  end

  while true do
    msg = sp.gets
    unless msg.nil?
      cod_arduino = msg.split(":")
      vacancy = get_status(cod_arduino[0])
      if vacancy.nil?
        save_status_controll(cod_arduino[0])
      elsif !vacancy.nil?
        st = @db[:status_controlls].filter(:vacancy_id => vacancy[:id]).order(:id).last
        if vacancy[:status] !=  RESTRICTED
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
