module Koha::Biblio   
  ### Biblio and Item Methods ###
  
  # This method will get the biblio record from koha given the biblionumber
  def find_biblio biblionumber, opts = {}
      biblionumber = biblionumber.to_s
      JSON.parse(get "biblio/#{biblionumber}", opts)
  end
  
  # This method will get the item records from koha given the biblionumber
   def find_biblio_items biblionumber, opts = {}
       biblionumber = biblionumber.to_s
       JSON.parse(get "biblio/#{biblionumber}/items", opts)
   end
  
  
  # wrapper to check if a biblio is holdable
  # take a koha biblio number and standard client opts
  def biblio_holdable?(biblionumber, opts = {})
    is_holdable?(:biblio, biblionumber, opts )
  end
  
  # makes a hold on the title.
  # takes a koha biblionumber and the client opts, which should include either a borrowernumber or user_name param.
  # returns a hash of the pickup location and hold date.
  def hold_biblio(biblionumber, opts = {})
    JSON.parse(post  "biblio/#{biblionumber}/hold", opts )
  end
  
  # wrapper to check a biblio items holdabale statues. 
  # takes a koha bilionumber and standard client opts
  # this returns just a hash of the items and their status, no need to evaulate.
  def biblio_items_holdable?(biblionumber, opts = {} )
    opts ||= {} 
    opts[:holdable] = "items_holdable_status"
    opts[:evaluate] ||= false
    is_holdable?(:biblio, biblionumber, opts)
  end
  
  # wrapper to check is an item is holdable
  def item_holdable?(itemnumber, opts = {})
    is_holdable?(:item, itemnumber, opts)
  end
  
  # makes a hold on the title.
  # takes a koha biblionumber and the client opts, which should include either a borrowernumber or user_name param.
  # returns a hash of the pickup location and hold date.
  def hold_item(itemnumber, opts = {})
    JSON.parse( post  "item/#{itemnumber}/hold", opts )
  end
  
  def is_holdable?(koha_type, identifier, opts = {} )
    opts ||= {}
    opts[:evaluate] = :is_holdable unless opts[:evaluate] == false
    holdable = opts[:holdable] ? opts[:holdable] : "holdable" 
    koha_type = koha_type.to_s == "item" ? "item" : "biblio"
    identifier = identifier.to_s
    get "#{koha_type}/#{identifier}/#{holdable}", opts
  end
end