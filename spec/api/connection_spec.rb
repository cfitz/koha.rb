require 'spec_helper'
require 'base64'

describe "Koha::Connection" do
  
  context "setup_raw_request" do
    
    before(:each) do 
      @c = Koha::Connection.new
      @base_url = "http://localhost:8983/koha/rest.pl"
      @client = Koha::Client.new @c, :url => @base_url
    end
       
    it "should set up a get request" do
      req = @c.send :setup_raw_request, {:headers => {"content-type" => "application/json"}, :method => :get, :uri => URI.parse(@base_url + "/biblio/1/items?borrowername=cf")}
      headers = {}
      req.each_header{|k,v| headers[k] = v}
      req.method.should == "GET"
      headers.should == {"content-type"=>"application/json"}
    end
    
     it "should set up a post request" do
        req = @c.send :setup_raw_request, {:headers => {"content-type" => "application/json"}, :method => :post, :uri => URI.parse(@base_url + "/biblio/1/items?borrowername=cf")}
        headers = {}
        req.each_header{|k,v| headers[k] = v}
        req.method.should == "POST"
        headers.should == {"content-type"=>"application/json"}
    end
    
     it "should set up a post request" do
        req = @c.send :setup_raw_request, {:headers => {"content-type" => "application/json"}, :method => :put, :uri => URI.parse(@base_url + "/biblio/1/items?borrowername=cf")}
        headers = {}
        req.each_header{|k,v| headers[k] = v}
        req.method.should == "PUT"
        headers.should == {"content-type"=>"application/json"}
    end
    
     it "should raise error if something weird is set as method" do
        expect { @c.send :setup_raw_request, {:headers => {"content-type" => "application/json"}, :method => :head, :uri => URI.parse(@base_url + "/biblio/1/items?borrowername=cf")} }.to raise_error("Only :get, :post and :head http method types are allowed.")
       
    end
    
  end

  context "read timeout configuration" do
    let(:client) { mock.as_null_object }

    let(:http) { mock(Net::HTTP).as_null_object }

    subject { Koha::Connection.new } 

    before do
      Net::HTTP.stub(:new) { http }
    end

    it "should configure Net:HTTP read_timeout" do
      http.should_receive(:read_timeout=).with(42)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :read_timeout => 42}
    end

    it "should use Net:HTTP default read_timeout if not specified" do
      http.should_not_receive(:read_timeout=)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
    end
  end

  context "open timeout configuration" do
    let(:client) { mock.as_null_object }

    let(:http) { mock(Net::HTTP).as_null_object }

    subject { Koha::Connection.new } 

    before do
      Net::HTTP.stub(:new) { http }
    end

    it "should configure Net:HTTP open_timeout" do
      http.should_receive(:open_timeout=).with(42)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :open_timeout => 42}
    end

    it "should use Net:HTTP default open_timeout if not specified" do
      http.should_not_receive(:open_timeout=)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
    end
  end

  context "connection refused" do
    let(:client) { mock.as_null_object }

    let(:http) { mock(Net::HTTP).as_null_object }
    let(:request_context) {
      {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :open_timeout => 42}
    }
    subject { Koha::Connection.new } 

    before do
      Net::HTTP.stub(:new) { http }
    end

    it "should configure Net:HTTP open_timeout" do
      http.should_receive(:request).and_raise(Errno::ECONNREFUSED)
      lambda {
        subject.execute client, request_context
      }.should raise_error(Errno::ECONNREFUSED, /#{request_context}/)
    end
    
      # there is a strange ruby bug about closing a connection....this catches it. 
     it "should raise NoMethodError if a non-method is called" do
        http.should_receive(:request).and_raise(NoMethodError)
        lambda {
          subject.execute client, request_context
        }.should raise_error(NoMethodError, /NoMethodError/)
      end
      
      it "should raise NoMethodError if a non-method is called" do
          error = NoMethodError.new("undefined method `closed?' for nil:NilClass")
          http.should_receive(:request).and_raise(error) 
          lambda {
            subject.execute client, request_context
          }.should raise_error(Errno::ECONNREFUSED)
        end
    
  end
  
  describe "basic auth support" do
    let(:http) { mock(Net::HTTP).as_null_object }
    
    before do
      Net::HTTP.stub(:new) { http }
    end
    
    it "sets the authorization header" do
      http.should_receive(:request) do |request|
        request.fetch('authorization').should == "Basic #{Base64.encode64("joe:pass")}".strip
        mock(Net::HTTPResponse).as_null_object
      end
      Koha::Connection.new.execute nil, :uri => URI.parse("http://joe:pass@localhost/koha/rest.pl"), :method => :get
    end
  end
  
  describe "proxy support" do
    it "set the proxy" do
      @mock_proxy = mock('Proxy')
      @mock_proxy.should_receive(:new).with("localhost", 80).and_return( mock(Net::HTTP).as_null_object)  
      Net::HTTP.should_receive(:Proxy).with("proxy", 80, nil, nil).and_return(@mock_proxy)
      Koha::Connection.new.execute nil, :uri => URI.parse("http://localhost/koha/rest.pl"),  :method => :get, :proxy =>  URI.parse("http://proxy/pass.pl")
    end
  end
  
end