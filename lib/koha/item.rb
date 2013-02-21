require 'hashie'
class Koha::Item < Hashie::Mash


  def holdable?(opts = {})
     opts = borrower_opts(opts)
     client.item_holdable?(itemnumber, opts)
  end
  
  protected
  
  
  def borrower_opts(opts = {})
    opts ||= {}
    opts[:borrowernumber] = opts[:borrower].to_s  if opts[:borrower]
    opts
  end


end