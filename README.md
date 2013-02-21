# Koha [![Build Status](https://secure.travis-ci.org/cfitz/koha.png)](https://secure.travis-ci.org/cfitz/koha.png)

A simple ruby wrapper from the Koha ILS RESTFUL API. 

### Prerequisites

You must install the RESTFUL api code to your instance of Koha. This project can be found here =>
http://git.biblibre.com/?p=koha-restful;a=summary

## Installation

Add this line to your application's Gemfile:

    gem 'koha'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install koha

## Usage

Here a quick irb walk-through...

> $ irb  

> 1.9.3-p286 :001 > require 'koha'  
  => true 

Make a Connection...  

  > 1.9.3-p286 :002 > k = Koha.connect({:url => "http://my.library.se/cgi-bin/koha/rest.pl"} )  
  > => #<Koha::Client:0x007fbcec9b6fd0 @uri=#<URI::HTTP:0x007fbcec9c3a00 URL:http://my.library.se/cgi-bin/koha/rest.pl/>, @proxy=nil, @connection=#<Koha::Connection:0x007fbcec9b6ff8>, @options={:url=>"http://my.library.se/cgi-bin/koha/rest.pl"}>  

now get branch information...  

  > 1.9.3-p286 :003 > k.branches  
  > => [ { "name"=>"World Maritime University Library", "code"=>"WMU"}, { "name"=>"ebrary", "code"=>"EBR" } ]   


find a bibliographic record  
  > 1.9.3-p286 :006 > k.find_biblio("17454")  
  > => [{"withdrawn"=>"1", "biblioitemnumber"=>"17454", .......  

check is an biblio is holdable.....  
  > 1.9.3-p286 :009 >    k.biblio_holdable?("17454" )  
  > => false  
 
... for a specific user ...  
  > 1.9.3-p286 :011 >  k.biblio_holdable?("17454", :borrowernumber => "544" )  
  > => true  


... by user name ...  
  > 1.9.3-p286 :012 >  k.biblio_holdable?("17454", :borrowername => "cf" )  
  > => true  
 
get the user's holds.  
  > 1.9.3-p286 :013 >  k.user_holds :borrowername => "cf"  
  > => [{"itemnumber"=>nil, "branchname"=>"World Maritime University Library", "itemcallnumber"=>nil, "hold_id"=>nil, "reservedate"=>"2013-02-20", "barcode"=>nil, "found"=>nil, "biblionumber"=>"76356", "cancellationdate"=>nil, "title"=>"Asian approaches to international law and the legacy of colonialism and imperialism :", "rank"=>"1", "branchcode"=>"WMU"}]  

or get the user's issues  
 
  > 1.9.3-p286 :014 >  k.user_issues :borrowernumber => "544"   
  > => [{"itemnumber"=>"42414", "itemcallnumber"=>"KD1819 .H54 2003", "barcode"=>"022593", "date_due"=>"2013-03-11T23:59:00", "renewable"=>true, "issuedate"=>"2012-11-21T00:00:00", "biblionumber"=>"17454", "title"=>"Maritime law", "borrowernumber"=>"544", "branchcode"=>"WMU"}]  



### Development

Checkout the code. rake will run the tests. rake coverage will generate coverage. rake yard will generate documentation. 


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
2.5 Write the code and add tests. 
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
