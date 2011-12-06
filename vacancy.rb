class Vacancy
  require '../arduino/dependence_provider'
  require 'rubygems'
  
  include DependenceProvider
  
  dependence = Vacancy.new
  
  @db = dependence.connection
  sp = dependence.serial_port

  AVAILABLE   = "0"
  RESTRICTED  = "1"
  BUSY        = "2"
  
  
  def self.get_vacancy(cod_arduino)
    @db[:vacancies].filter(:cod_arduino => cod_arduino).order(:id)
  end
  
  def self.update_vacancy(cod_arduino, status)
    @db[:vacancies].filter(:cod_arduino => cod_arduino).update(:status => status)
  end
  
  def self.update_status_controll(cod_arduino)
    @db.transaction do
      vacancy = get_vacancy(cod_arduino).last
      old_status = vacancy[:status]
      update_vacancy(cod_arduino, AVAILABLE)

      @db[:status_controlls].filter(:vacancy_id => vacancy[:id], :time_end => nil).update(:time_end => Time.now, :current_status => AVAILABLE, :old_status => old_status)
    end
  end
  
  def self.save_status_controll(cod_arduino)
    @db.transaction do
      vacancy = get_vacancy(cod_arduino).last

      update_vacancy(cod_arduino, BUSY)
      @db[:status_controlls].insert(:vacancy_id => vacancy[:id], :timebegin => Time.now, :current_status => BUSY)
    end
  end
  
  while true do
    msg = sp.gets
    p msg
    unless msg.nil?
      cod_arduino = msg.split(":")
      vacancy = get_vacancy(cod_arduino[0]).last
       if !vacancy.nil?
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
