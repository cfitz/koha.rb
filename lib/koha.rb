$: << "#{File.dirname(__FILE__)}" unless $:.include? File.dirname(__FILE__)

require 'rubygems'

module Koha
  
  %W(Client Error Connection Uri Version).each{|n| autoload n.to_sym, "koha/#{n.downcase}"}
  
  def self.version; "0.0.2" end
  
  VERSION = self.version
  
  def self.connect *args
    driver = Class === args[0] ? args[0] : Koha::Connection
    opts = Hash === args[-1] ? args[-1] : {}
    Client.new driver.new, opts
  end
  
  
end