module Koha::Info
  

   ### Info Methods ###

   # returns a hash of [ { :code => "1", :name => "Our Branch Name "}]
   def branches opts= {}
      JSON.parse(get "branches", opts)
   end
  
  
  
end