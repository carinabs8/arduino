class Banco
  require 'sequel'
  
  def initialize(adapter, host, database, user, password)
    db = Sequel.connect(:adapter => adapter, :host => host, :database =>database, :user => user, :password => password)
  end
   #DB.create_table :arduino_vagas do
  #  primary_key :id
  #  String :name
  #  String :status
  #end
  
end