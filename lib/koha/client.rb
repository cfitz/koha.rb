require 'json'

class Koha::Client
  
  attr_reader :connection, :uri, :proxy, :options
  
  def initialize connection, options = {}
    @proxy = @uri = nil
    @connection = connection
    unless false === options[:url]
      url = options[:url] ? options[:url].dup : 'http://localhost/cgi-bin/koha/rest.pl/'
      url << "/" unless url[-1] == ?/
      @uri = Koha::Uri.create url
      if options[:proxy]
        proxy_url = options[:proxy].dup
        proxy_url << "/" unless proxy_url.nil? or proxy_url[-1] == ?/
        @proxy = Koha::Uri.create proxy_url if proxy_url
      end
    end
    @options = options
  end
   
  # returns the uri proxy if present,
  # otherwise just the uri object.
  def base_uri
    @proxy ? @proxy : @uri
  end
  
  # Create the get, post, and head methods
  %W(get post put delete).each do |meth|
     class_eval <<-RUBY
     def #{meth} path, opts = {}, &block
       send_and_receive path, opts.merge(:method => :#{meth}), &block
     end
     RUBY
   end
 
  
  # +send_and_receive+ is the main request method responsible for sending requests to the +connection+ object.
  # 
  # "path" : A string value that directs the client to the API REST method
  # "opts" : A hash, which can contain the following keys:
  #   :method : optional - the http method (:get, :post or :put)
  #   :params : optional - the query string params in hash form
  # All other options are passed right along to the connection's +send_and_receive+ method (:get, :post, or :put)
  # 
  #
  # creates a request context hash,
  # sends it to the connection's +execute+ method
  # which returns a simple hash,
  # then passes the request/response into +adapt_response+.
  def send_and_receive path, opts
    request_context = build_request path, opts
    [:open_timeout, :read_timeout].each do |k|
      request_context[k] = @options[k]
    end
    execute request_context
  end
  
  # send a request to the connection to be submitted
  def execute request_context
    raw_response = connection.execute self, request_context
    adapt_response(request_context, raw_response) unless raw_response.nil?
  end
  
  # +build_request+ accepts a path and options hash,
  # then prepares a normalized hash to return for sending
  # +build_request+ sets up the uri/query string
  # and converts the +data+ arg to form-urlencoded,
  # returns a hash with the following keys:
  #   :method
  #   :params
  #   :data
  #   :uri
  #   :path
  #   :query
  
  def build_request path, opts
    raise "path must be a string or symbol, not #{path.inspect}" unless [String,Symbol].include?(path.class)
    path = path.to_s
    opts[:proxy] = proxy unless proxy.nil?
    opts[:method] ||= :get
    raise "The :data option can only be used if :method => :post" if opts[:method] != :post and opts[:data]
    opts[:params] ||= {}
    opts[:data] ||= {}
    if opts[:method] == :get #for get q's we want user info in the params, for all others it will be a data post/put param
      opts[:params][:borrowernumber] = opts[:borrowernumber] if opts[:borrowernumber]
      opts[:params][:user_name] = opts[:borrowername] if opts[:borrowername]
    else
      opts[:data][:borrowernumber] = opts[:borrowernumber] if opts[:borrowernumber]
      opts[:data][:user_name] = opts[:borrowername] if opts[:borrowername]
    end
    query = Koha::Uri.to_params(opts[:params]) unless opts[:params].empty?
    opts[:query] = query
    
    if opts[:data].is_a? Hash
      opts[:data] = Koha::Uri.to_params opts[:data]
      opts[:headers] ||= {}
      opts[:headers]['Content-Type'] ||= 'application/x-www-form-urlencoded; charset=UTF-8'
    end
    
    opts[:path] = path
    if base_uri
      opts[:uri] = URI.join(base_uri, path.to_s)
      opts[:uri].merge!("?#{query}" ) if query
    end
    opts
  end
  
  
  #  A mixin for used by #adapt_response
   module Context
     attr_accessor :request, :response
   end

   # This method will evaluate the :body value
   # if the request has an :evaulte value, the response is send to
   # the evaluate_json_response, which returns just the node. 
   # this is a convience to simply return "false" or "true" and not a bunch of stupid
   # json that has nothing that makes any god-damn sense. 
   # ... otherwise, the json is simply returned.
   def adapt_response request, response
     raise "The response does not have the correct keys => :body, :headers, :status" unless
       %W(body headers status) == response.keys.map{|k|k.to_s}.sort
     raise Koha::Error::Http.new request, response unless [200,302].include? response[:status]
     result = request[:evaluate] ? evaluate_json_response( response, request[:evaluate]) : response[:body]
     result.extend Context
     result.request, result.response = request, response
     result
   end
  
  
  
  ##### KOHA REST API METHODS #######
  
  ### Info Methods ###
  
  # returns a hash of [ { :code => "1", :name => "Our Branch Name "}]
  def branches opts= {}
     JSON.parse(get "branches", opts)
  end
  
  
  ### USER Methods ###
  
  # returns a hash of all the users
  def all_users opts= {}
    JSON.parse(get "user/all", opts )
  end
  
  # returns a hash of patrons enrolled today
  def today_users opts= {}
    JSON.parse(get "user/today", opts)
  end
  
  
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
    
    
  protected

  # this is used to retrun a ruby primitive based on a json node. For example holdable returns { "is_holdable" : true, "reasons" : [] }
  # and we just want true. 
  def evaluate_json_response response, node
    json = JSON.parse(response[:body])
    case json[node.to_s] # god-damn perl messing up my json
    when "true" 
      return true
    when "false"
      return false
    else
      return json[node.to_s]
    end
  end
  
  
  
   
end