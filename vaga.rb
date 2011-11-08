class Vacancy
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  require 'mysql'
  @db = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  sp = SerialPort.new("COM4", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  

  def self.get_vacancy(cod_arduino)
    vacancy = @db[:vacancies].filter(:cod_arduino => cod_arduino).order(:id)
  end
  
  def self.update_status_controll(cod_arduino)
      vacancy = get_vacancy(cod_arduino)
      vacancy.update(:status => AVAILABLE)
      old_status = vacancy[:old_status]
      
      @db[:status_controlls].filter(:vacancy_id => vacancy[:id], :time_end => nil).update(:time_end => Time.now, :current_status => AVAILABLE, :old_status => old_status)
  end

  def self.save_status_controll(cod_arduino)
      vacancy = get_vacancy(cod_arduino)
      vacancy.update(:status => BUSY)
      @db[:status_controlls].insert(:vacancy_id => vacancy[:id], :timebegin => Time.now, :current_status => BUSY)
  end

  while true do
    msg = sp.gets
    unless msg.nil?
      cod_arduino = msg.split(":")
      vacancy = get_vacancy(cod_arduino[0])
       if !vacancy.last.nil?
        status = @db[:status_controlls].filter(:vacancy_id => vacancy[:id]).order(:id).last
        if status.nil?
          save_status_controll(cod_arduino[0])
        elsif !status.nil?
          if vacancy[:status] !=  RESTRICTED
            if status[:time_end].nil?
              self.update_status_controll(cod_arduino[0])
              if cod_arduino[1] == BUSY
                save_status_controll(cod_arduino[0])
              end
            end
  
            if !status[:time_end].nil? and cod_arduino[1] == BUSY
              save_status_controll(cod_arduino[0])
            end
          end
        end
      end
    end
    sleep(1)
   end
end
