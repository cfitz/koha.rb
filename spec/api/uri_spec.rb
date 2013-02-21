require 'spec_helper'
describe "Koha::Uri" do
  
  context "class-level methods" do
    
    let(:uri){ Koha::Uri }
    
    it "should return a URI object with a trailing slash" do
      u = uri.create 'http://koha.org'
      u.path[0].should == ?/
    end
  
    it "should return the bytesize of a string" do
      uri.bytesize("test").should == 4
    end
  
  
  
    context "escape_query_value" do
      
      it 'should escape &' do
        uri.to_params(:biblionumber => "&").should == 'biblionumber=%26'
      end

       it 'should escape &' do
          uri.to_params({:biblionumber => "&" }, false).should == 'biblionumber=&'
        end

          it 'should escape &' do
              uri.to_params(:biblionumber => [1,2,3] ).should == 'biblionumber=1+2+3'
            end


      it 'should convert spaces to +' do
        uri.to_params(:biblionumber => "me and you").should == 'biblionumber=me+and+you'
      end

      it 'should escape comlex queries, part 1' do
        my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
        expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
        uri.to_params(my_params).should == expected
      end

      it 'should escape complex queries, part 2' do
        my_params = {'q' => '+popularity:[10 TO *] +section:0'}
        expected = 'q=%2Bpopularity%3A%5B10+TO+%2A%5D+%2Bsection%3A0'
        uri.to_params(my_params).should == expected
      end
      
      it 'should escape properly' do
        uri.escape_query_value('+').should == '%2B'
        uri.escape_query_value('This is a test').should == 'This+is+a+test'
        uri.escape_query_value('<>/\\').should == '%3C%3E%2F%5C'
        uri.escape_query_value('"').should == '%22'
        uri.escape_query_value(':').should == '%3A'
      end

      it 'should escape brackets' do
        uri.escape_query_value('{').should == '%7B'
        uri.escape_query_value('}').should == '%7D'
      end

      it 'should escape exclamation marks!' do
        uri.escape_query_value('!').should == '%21'
      end
      
    end
    
  end
  
end