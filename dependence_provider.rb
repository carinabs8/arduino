module DependenceProvider
  require 'sequel'
  
  def connection
    @db = Sequel.connect(:adapter => "postgres", :host => "localhost", :database => "projet_final_development", :user => "postgres", :password => "starfaty")
  end
end