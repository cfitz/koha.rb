require 'uri'

module Koha::Uri
  extend self
  
  
  def create url
    ::URI.parse url[-1] == ?/ ? url : "#{url}/"
  end
  
  # takes a key and value and returns it as a query string
  # @param k [String] 
  # @param v [String]
  # @param escape [Boolean]
  def build_param(k,v, escape = true)
    escape ? 
      "#{escape_query_value(k)}=#{escape_query_value(v)}" :
      "#{k}=#{v}"
  end

  # issue with ruby 1.8, which uses String#size. ruby 1.9 uses String#bytesize.
  if ''.respond_to?(:bytesize)
    def bytesize(string)
      string.bytesize
    end
  else
    def bytesize(string)
      string.size
    end
  end

  # Creates a ILSDI based query string.
    def to_params(params, escape = true)
      mapped = params.map do |k, v|
        next if v.to_s.empty?
        if v.class == Array 
          build_param k, v.join("+"), false
        else
          build_param k, v, escape
        end
      end
      mapped.compact.join("&")
    end


  # Performs URI escaping so that you can construct proper
  # (Stolen from Rack).
  def escape_query_value(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/u) {
      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
    }.tr(' ', '+')
  end
  
  
end