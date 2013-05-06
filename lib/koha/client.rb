require 'json'

class Koha::Client
  
  include Koha::Info
  include Koha::User
  include Koha::Biblio
  
  attr_reader :connection, :uri, :proxy, :options
  
  def initialize connection, options = {}
    @proxy = @uri = nil
    @connection = connection
    unless false === options[:url]
      url = options[:url] ? options[:url].dup : 'http://localhost/cgi-bin/koha/rest.pl/'
      @uri = Koha::Uri.create url
      if options[:proxy]
        proxy_url = options[:proxy].dup
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
       send_request path, opts.merge(:method => :#{meth}), &block
     end
     RUBY
   end
 
  
  #  the main request method responsible for sending requests.
  #  @param path [String]  the client's API REST method
  #  @param opts [Hash] A hash which can contain the following keys: 
  #       [:method] : optional - the http method (:get, :post or :put)
  #       [:params] : optional - the query string params in hash form
  #       All other options are passed to the execute method      
  def send_request path, opts
    request_context = build_request path, opts
    [:open_timeout, :read_timeout].each do |k|
      request_context[k] = @options[k]
    end
    request request_context
  end
   

  # Sets up the uri/query string
  #  @param path [String, Symbol]  the request path
  #  @param opts [Hash] The options for the REST call. Can include:  
  #     :method, :params, :data, :uri, :path, :query
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
    opts[:path] = path
    if base_uri
      opts[:uri] = URI.join(base_uri, path.to_s)
      opts[:uri].merge!("?#{query}" ) if query
    end
    opts
  end
   
  #  A simple mixin for process_response.
   module Response
     attr_accessor :request, :response
   end

   # Recieves the request and response from the connection and format it. Returns an object with the response body and @request and @response.
   def process_response request, response
     raise "The response does not have the correct keys => :body, :headers, :status" unless
       %W(body headers status) == response.keys.map{|k|k.to_s}.sort
     raise Koha::Error::Http.new request, response unless [200,302].include? response[:status]
     result = request[:evaluate] ? evaluate_json_response( response, request[:evaluate]) : response[:body]
     result.extend Response
     result.request, result.response = request, response
     result
   end
     
  protected
  # process the request to the connection to be submitted
  #  @param request_context [Hash]  A hash created by the build_request method 
  def request request_context
   raw_response = connection.request request_context
   process_response(request_context, raw_response) unless raw_response.nil?
  end


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