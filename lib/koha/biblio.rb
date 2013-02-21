require 'hashie'
require 'json'
class Koha::Biblio
  
  attr_accessor :biblionumber, :client, :items, :request, :response
  
  def initialize( biblionumber, json, client = nil)
    @biblionumber = biblionumber
    @client = client if client
    @items = []
    json.each  { |j| items << Koha::Item.new(j.merge({"client" => client.dup})) }
  end
  
  
  def holdable?(opts = {}) 
    opts = borrower_opts(opts)
    @client.biblio_holdable?( @biblionumber, opts )
  end
  
  def items_holdable?(opts = {})
    opts = borrower_opts(opts)
    puts opts
    @client.biblio_items_holdable?(@biblionumber, opts)
  end
  
  protected
  
  
  def borrower_opts(opts = {})
    opts ||= {}
    opts[:borrowernumber] = opts[:borrower].to_s  if opts[:borrower]
    opts
  end
    
end
