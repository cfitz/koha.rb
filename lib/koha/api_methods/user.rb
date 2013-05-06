module Koha::User
  ### USER Methods ###
  
  # get all the users
  # @param opts [Hash] standard opts hash to pass to http client
  def all_users opts= {}
    JSON.parse(get "user/all", opts )
  end
  
  # get all today's users
  # @param opts [Hash] standard opts hash to pass to http client
  def today_users opts= {}
    JSON.parse(get "user/today", opts)
  end
  
  # get all today's users
  # @param opts [Hash] standard opts hash to pass to http client
  def user_holds opts= {}
    path, opts = build_user_path("holds", opts)
    JSON.parse(get path, opts)
  end
  
  def delete_hold opts= {}
    opts[:evaluate] ||= "canceled"
    opts[:prefix] = opts[:biblionumber] ? "biblio" : "item" #delete end-point is like :/user/byid/544/holds/biblio/1
    path, opts = build_user_path("holds", opts)
    return  delete(path, opts)
  end
    
  def user_issues opts= {}
    path, opts = build_user_path("issues", opts)
    JSON.parse(get path, opts)
  end
  
  def renew_issue opts={}
    path, opts = build_user_path("issues", opts)
    JSON.parse(put path, opts)
  end
  
  private 
  
  def build_user_path koha_method, opts= {}
    raise ArgumentError unless (  opts[:borrowernumber] or opts[:borrowername] ) #we have to be passed either a name or number
    borrowernumber, borrowername = opts.delete(:borrowernumber), opts.delete(:borrowername)
    biblionumber, itemnumber = opts.delete(:biblionumber), opts.delete(:itemnumber)
    prefix = opts.delete(:prefix)
    path = borrowernumber ? "user/byid/#{borrowernumber}/#{koha_method}/" : "user/#{borrowername}/#{koha_method}/" 
    path << prefix if prefix 
    path << "/#{itemnumber}/" if itemnumber
    path << "/#{biblionumber}/" if ( biblionumber && itemnumber.nil?) 
    return  path, opts
  end
  
end