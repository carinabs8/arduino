class Banco
  require 'sequel'
  
  def initialize(adapter, host, database, user, password)
    db = Sequel.connect(:adapter => adapter, :host => host, :database =>database, :user => user, :password => password)
  end
  
end