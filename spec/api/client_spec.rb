require 'spec_helper'
describe "Koha::Client" do
  
  module ClientHelper
    def client
      @client ||= (
        connection = Koha::Connection.new
        Koha::Client.new connection, :url => "http://localhost/koha", :read_timeout => 42, :open_timeout=>43
      )
    end
  end
  
  context "initialize" do
    it "should accept whatevs and set it as the @connection" do
      Koha::Client.new(:whatevs).connection.should == :whatevs
    end
    
    
  end
  
  context "request" do
    include ClientHelper
    it "should forward these method calls the #connection object" do
      [:get, :post, :put].each do |meth|
        client.connection.should_receive(:request).
            and_return({:status => 200, :body => "{}", :headers => {}})
        client.send_request '', :method => meth, :params => {}, :data => nil, :headers => {}
      end
    end

    it "should be timeout aware" do
      [:get, :post, :put].each do |meth|
        client.connection.should_receive(:request).with( hash_including(:read_timeout => 42, :open_timeout=>43))
        client.send_request '', :method => meth, :params => {}, :data => nil, :headers => {}
      end
    end
  end

  context "post" do
    include ClientHelper
    it "should pass the expected params to the connection's #request method" do
      request_opts = {:data => "the data", :method=>:post, :headers => {"Content-Type" => "text/plain"}}
      client.connection.should_receive(:request).
        with(hash_including(request_opts)).
        and_return(
          :body => "",
          :status => 200,
          :headers => {"Content-Type"=>"text/plain"}
        )
      client.post "biblio/update", request_opts
    end
  end
  
 
  
  context "process_respons" do
    include ClientHelper
  
    
  end
  
  context "build_request" do
    include ClientHelper
    it 'should return a request context array' do
      result = client.build_request('select',
        :method => :get,
        :params => {},
        :borrowernumber => "512",
        :borrowername => "cf"
      )
      [/user_name=cf/, /borrowernumber=512/].each do |pattern|
        result[:query].should match pattern
      end
    end
  
  
  
    # Check responses to see how the KOHA RESTFUL API v1.0 responds.
    context "koha methods" do
      include ClientHelper
      
      # branches
      it "should call the REST API branch method with #client" do
        stub_request(:get, "http://localhost/koha/branches").to_return(:status => 200, :body =>
        "[{\"name\":\"World Maritime University Library\",\"code\":\"WMU\"},{\"name\":\"ebrary\",\"code\":\"EBR\"}]",
         :headers => {})
        client.branches
        WebMock.should have_requested(:get, "http://localhost/koha/branches")
      end
      
      
      # user
      it "should call the user/all method for #all_users" do
        stub_request(:get, "http://localhost/koha/user/all").to_return(:status => 200, :body => 
        "[{\"categorycode\":\"T\",\"B_address\":\"\",\"contactnote\":\"\",\"ethnicity\":null,\"email\":\"foo@wmu.se\",\"password\":\"1+1898juif\",\"B_country\":\"\",\"borrowernumber\":\"5\",\"lost\":\"0\",\"branchcode\":\"WMU\",\"streettype\":null,\"altcontactaddress3\":\"\",\"contactfirstname\":null,\"title\":\"\",\"attributes\":[],\"ethnotes\":null,\"relationship\":null,\"mobile\":\"\",\"fax\":\"\",\"altcontactphone\":\"\",\"contactname\":\"WMU\",\"country\":\"Sweden\",\"dateenrolled\":\"2010-02-03\",\"altcontactstate\":null,\"guarantorid\":\"0\",\"address2\":\"\",\"borrowernotes\":\"\",\"dateexpiry\":\"2018-05-03\",\"sort2\":\"\",\"contacttitle\":null,\"phonepro\":\"+46-40-35 63 90\",\"smsalertnumber\":null,\"B_streetnumber\":null,\"emailpro\":\"mbf@wmu.se\",\"firstname\":\"Michael\",\"altcontactcountry\":\"\",\"gonenoaddress\":\"0\",\"othernames\":\"\",\"state\":null,\"dateofbirth\":null,\"altcontactaddress2\":\"\",\"B_streettype\":null,\"debarred\":null,\"B_state\":null,\"address\":\"PO Box 500\",\"B_address2\":\"\",\"privacy\":\"1\",\"streetnumber\":\"\",\"surname\":\"BALDAUF\",\"cardnumber\":\"MBF\",\"altcontactsurname\":\"\",\"altcontactzipcode\":\"\",\"opacnote\":\"\",\"altcontactfirstname\":\"\",\"userid\":\"mbf\",\"B_zipcode\":\"\",\"B_email\":\"\",\"city\":\"Malm\",\"B_phone\":\"\",\"debarredcomment\":null,\"initials\":\"MB\",\"sort1\":\"\",\"flags\":null,\"zipcode\":\"20124\",\"phone\":\"\",\"sex\":\"M\",\"altcontactaddress1\":\"\",\"B_city\":\"\"}]"
        )
        client.all_users
        WebMock.should have_requested(:get, "http://localhost/koha/user/all")
      end
        
        
      it "should call the user/all method for #all_users" do
        stub_request(:get, "http://localhost/koha/user/today").to_return(:status => 200, :body => 
        "[{\"categorycode\":\"T\",\"B_address\":\"\",\"contactnote\":\"\",\"ethnicity\":null,\"email\":\"foo@wmu.se\",\"password\":\"1+1898juif\",\"B_country\":\"\",\"borrowernumber\":\"5\",\"lost\":\"0\",\"branchcode\":\"WMU\",\"streettype\":null,\"altcontactaddress3\":\"\",\"contactfirstname\":null,\"title\":\"\",\"attributes\":[],\"ethnotes\":null,\"relationship\":null,\"mobile\":\"\",\"fax\":\"\",\"altcontactphone\":\"\",\"contactname\":\"WMU\",\"country\":\"Sweden\",\"dateenrolled\":\"2010-02-03\",\"altcontactstate\":null,\"guarantorid\":\"0\",\"address2\":\"\",\"borrowernotes\":\"\",\"dateexpiry\":\"2018-05-03\",\"sort2\":\"\",\"contacttitle\":null,\"phonepro\":\"+46-40-35 63 90\",\"smsalertnumber\":null,\"B_streetnumber\":null,\"emailpro\":\"mbf@wmu.se\",\"firstname\":\"Michael\",\"altcontactcountry\":\"\",\"gonenoaddress\":\"0\",\"othernames\":\"\",\"state\":null,\"dateofbirth\":null,\"altcontactaddress2\":\"\",\"B_streettype\":null,\"debarred\":null,\"B_state\":null,\"address\":\"PO Box 500\",\"B_address2\":\"\",\"privacy\":\"1\",\"streetnumber\":\"\",\"surname\":\"BALDAUF\",\"cardnumber\":\"MBF\",\"altcontactsurname\":\"\",\"altcontactzipcode\":\"\",\"opacnote\":\"\",\"altcontactfirstname\":\"\",\"userid\":\"mbf\",\"B_zipcode\":\"\",\"B_email\":\"\",\"city\":\"Malm\",\"B_phone\":\"\",\"debarredcomment\":null,\"initials\":\"MB\",\"sort1\":\"\",\"flags\":null,\"zipcode\":\"20124\",\"phone\":\"\",\"sex\":\"M\",\"altcontactaddress1\":\"\",\"B_city\":\"\"}]"
        )
        client.today_users
        WebMock.should have_requested(:get, "http://localhost/koha/user/today")
      end
      
      it "should call the user holds method for #user_holds" do
        stub_request(:get, "http://localhost/koha/user/byid/1/holds/").to_return(:status => 200, :body => 
"[{\"itemnumber\":null,\"branchname\":\"World Maritime University Library\",\"itemcallnumber\":null,\"hold_id\":null,\"reservedate\":\"2013-02-20\",\"barcode\":null,\"found\":null,\"biblionumber\":\"76356\",\"cancellationdate\":null,\"title\":\"Asian approaches to international law and the legacy of colonialism and imperialism :\",\"rank\":\"1\",\"branchcode\":\"WMU\"}]"         )
        client.user_holds(:borrowernumber => "1")
        WebMock.should have_requested(:get, "http://localhost/koha/user/byid/1/holds/")
      end
    
    
     it "should call the user issues method for #user_issues" do
        stub_request(:get, "http://localhost/koha/user/cf/issues/").to_return(:status => 200, :body => 
"[{\"itemnumber\":\"42414\",\"itemcallnumber\":\"KD1819 .H54 2003\",\"barcode\":\"022593\",\"date_due\":\"2013-03-11T23:59:00\",\"renewable\":true,\"issuedate\":\"2012-11-21T00:00:00\",\"biblionumber\":\"17454\",\"title\":\"Maritime law\",\"borrowernumber\":\"544\",\"branchcode\":\"WMU\"}]"         )
        client.user_issues(:borrowername => "cf")
        WebMock.should have_requested(:get, "http://localhost/koha/user/cf/issues/")
      end
    
    
      # biblio and items
      
      it "should call the biblio items method for #find_biblio" do
          stub_request(:get, "http://localhost/koha/biblio/1").to_return(:status => 200, :body => 
"[{\"withdrawn\":\"0\",\"biblioitemnumber\":\"1\",\"restricted\":null,\"wthdrawn\":\"0\",\"holdingbranchname\":\"World Maritime University Library\",\"notforloan\":\"0\",\"replacementpricedate\":\"2010-02-05\",\"itemnumber\":\"1\",\"ccode\":null,\"itemnotes\":null,\"location\":\"GEN\",\"itemcallnumber\":\"HD30.3 .A32 1989\",\"stack\":null,\"date_due\":\"\",\"barcode\":\"011376\",\"itemlost\":\"0\",\"uri\":null,\"materials\":null,\"datelastseen\":\"2010-02-05\",\"price\":null,\"issues\":null,\"homebranch\":\"WMU\",\"replacementprice\":null,\"more_subfields_xml\":null,\"cn_source\":\"lcc\",\"homebranchname\":\"World Maritime University Library\",\"booksellerid\":null,\"biblionumber\":\"1\",\"renewals\":null,\"holdingbranch\":\"WMU\",\"timestamp\":\"2012-11-28 07:47:23\",\"damaged\":\"0\",\"stocknumber\":null,\"cn_sort\":\"HD_00030_3_A32_1989\",\"reserves\":null,\"dateaccessioned\":\"2010-02-05\",\"datelastborrowed\":null,\"enumchron\":null,\"copynumber\":\"1\",\"permanent_location\":null,\"onloan\":null,\"paidfor\":null,\"itype\":\"BOOK\"}]" ) 
          client.find_biblio("1")
          WebMock.should have_requested(:get, "http://localhost/koha/biblio/1")
      end
    
    
     it "should call the biblio items method for #find_biblio" do
          stub_request(:get, "http://localhost/koha/biblio/1/items").to_return(:status => 200, :body => 
"[{\"withdrawn\":\"0\",\"biblioitemnumber\":\"1\",\"restricted\":null,\"wthdrawn\":\"0\",\"holdingbranchname\":\"World Maritime University Library\",\"notforloan\":\"0\",\"replacementpricedate\":\"2010-02-05\",\"itemnumber\":\"1\",\"ccode\":null,\"itemnotes\":null,\"location\":\"GEN\",\"itemcallnumber\":\"HD30.3 .A32 1989\",\"stack\":null,\"date_due\":\"\",\"barcode\":\"011376\",\"itemlost\":\"0\",\"uri\":null,\"materials\":null,\"datelastseen\":\"2010-02-05\",\"price\":null,\"issues\":null,\"homebranch\":\"WMU\",\"replacementprice\":null,\"more_subfields_xml\":null,\"cn_source\":\"lcc\",\"homebranchname\":\"World Maritime University Library\",\"booksellerid\":null,\"biblionumber\":\"1\",\"renewals\":null,\"holdingbranch\":\"WMU\",\"timestamp\":\"2012-11-28 07:47:23\",\"damaged\":\"0\",\"stocknumber\":null,\"cn_sort\":\"HD_00030_3_A32_1989\",\"reserves\":null,\"dateaccessioned\":\"2010-02-05\",\"datelastborrowed\":null,\"enumchron\":null,\"copynumber\":\"1\",\"permanent_location\":null,\"onloan\":null,\"paidfor\":null,\"itype\":\"BOOK\"}]" ) 
          client.find_biblio_items("1")
          WebMock.should have_requested(:get, "http://localhost/koha/biblio/1/items")
      end
    
     it "should call the biblio holdable for #biblio_holdable?" do
        stub_request(:get, "http://localhost/koha/biblio/1/holdable").to_return(:status => 200, :body =>
        "{\"is_holdable\":true,\"reasons\":[]}"  )
        client.biblio_holdable?("1").should be_true
        WebMock.should have_requested(:get, "http://localhost/koha/biblio/1/holdable")
     end
    
    # show how to use a borrowername
    it "should call the biblio holdable items for #biblio_items_holdable?" do
       stub_request(:get, "http://localhost/koha/biblio/1/items_holdable_status?user_name=cf").to_return(:status => 200, :body =>
       "{\"is_holdable\":true,\"reasons\":[]}"  )
       client.biblio_items_holdable?("1", :borrowername => "cf" ).should be_true
       WebMock.should have_requested(:get, "http://localhost/koha/biblio/1/items_holdable_status?user_name=cf")
    end
    
    # show how to use a borrowernumber
    it "should call the  items holdable API method for #item_holdable?" do
       stub_request(:get, "http://localhost/koha/item/74297/holdable?user_name=cf").to_return(:status => 200, :body =>
       "{\"is_holdable\":false,\"reasons\":[]}"  )
       client.item_holdable?("74297", :borrowername => "cf" ).should be_false
       WebMock.should have_requested(:get, "http://localhost/koha/item/74297/holdable?user_name=cf")
    end
    
    
    
    end  
  
    
  end
end