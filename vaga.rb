class Vacancy
  require 'rubygems'
  require 'serialport'
  require 'sequel'
  require 'mysql'
  @db = Sequel.connect(:adapter => "mysql", :host => "localhost", :database => "temp_development", :user => "root", :password => "")
  sp = SerialPort.new("COM3", 9600, 8, 1, SerialPort::NONE)
  
  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  

  def self.get_vacancy(cod_arduino)
    vacancy = @db[:vacancies].filter(:cod_arduino => cod_arduino).order(:id).last
  end
  
  def self.update_status_controll(cod_arduino)
      vacancy = get_vacancy(cod_arduino)
      @db[:vacancies].filter(:id => vacancy[:id]).update(:status => AVAILABLE)
      old_status = vacancy[:old_status]
      
      @db[:status_controlls].filter(:vacancy_id => vacancy[:id], :time_end => nil).update(:time_end => Time.now, :current_status => AVAILABLE, :old_status => old_status)
  end

  def self.save_status_controll(cod_arduino)
      vacancy = get_vacancy(cod_arduino)
      @db[:vacancies].filter(:id => vacancy[:id]).update(:status => BUSY)
      @db[:status_controlls].insert(:vacancy_id => vacancy[:id], :timebegin => Time.now, :current_status => BUSY)
  end

  while true do
    msg = sp.gets
    unless msg.nil?
      cod_arduino = msg.split(":")
      vacancy = get_vacancy(cod_arduino[0])
       if !vacancy.nil?
        st = @db[:status_controlls].filter(:vacancy_id => vacancy[:id]).order(:id).last
        if st.nil?
          save_status_controll(cod_arduino[0])
        elsif !st.nil?
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
    end
    sleep(0.5)
   end
end
