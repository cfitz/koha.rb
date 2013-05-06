require 'net/http'
require 'net/https'

class Koha::Connection

  def request request_context
    hclient = http_client request_context[:uri], request_context[:proxy], request_context[:read_timeout], request_context[:open_timeout]
    request = request_setup request_context
    request.body = request_context[:data] if request_context[:method] == :post and request_context[:data]
    begin
      response = hclient.request request
      charset = response.type_params["charset"]
      {:status => response.code.to_i, :headers => response.to_hash, :body => response.body}
    rescue Errno::ECONNREFUSED => e
      raise(Errno::ECONNREFUSED.new(request_context.inspect))
    end
  end

  protected
  # This returns a singleton of a Net::HTTP or Net::HTTP.Proxy 
  def http_client uri, proxy = nil, read_timeout = nil, open_timeout = nil
    @http ||= (
      http = if proxy
        proxy_user, proxy_pass = proxy.userinfo.split(/:/) if proxy.userinfo
        Net::HTTP.Proxy(proxy.host, proxy.port, proxy_user, proxy_pass).new uri.host, uri.port
      else
        Net::HTTP.new uri.host, uri.port
      end
      http.use_ssl = uri.port == 443 || uri.instance_of?(URI::HTTPS)
      http.read_timeout = read_timeout if read_timeout
      http.open_timeout = open_timeout if open_timeout
      http
    )
  end

  # takes the hash and sets up the basic params. 
   def request_setup request_context
     http_method = case request_context[:method]
     when :get
       Net::HTTP::Get
     when :post
       Net::HTTP::Post
     when :put
       Net::HTTP::Put
     when :delete
       Net::HTTP::Delete
     else
       raise "Only :get, :post and :delete http method types are allowed."
     end
     headers = request_context[:headers] || {}
     setup = http_method.new request_context[:uri].request_uri
     setup.initialize_http_header headers
     setup.basic_auth(request_context[:uri].user, request_context[:uri].password) if request_context[:uri].user && request_context[:uri].password
     setup
   end

end