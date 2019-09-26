require 'spec_helper'

describe Arango::AQL do
  before :all do
    @server = connect
    begin
      @server.drop_database("AQLDatabase")
    rescue
    end
    @database = @server.create_database("AQLDatabase")
  end

  before :each do
    begin
      @database.drop_collection('MyCollection')
    rescue
    end
    collection = @database.create_collection('MyCollection')
    collection.create_documents([
                                    {num: 1, _key: "FirstKey"}, {num: 1},
                                    {num: 1}, {num: 1}, {num: 1},
                                    {num: 1}, {num: 1}, {num: 2},
                                    {num: 2}, {num: 2}, {num: 3},
                                    {num: 2}, {num: 5}, {num: 2}
                                ])
  end

  after :each do
    begin
      @database.drop_collection('MyCollection')
    rescue
    end
  end

  after :all do
    @server.drop_database("AQLDatabase")
  end

  context "#new" do
    it "create a new AQL instance" do
      myAQL = @database.new_aql query: "FOR u IN MyCollection RETURN u.num"
      expect(myAQL.query).to eq "FOR u IN MyCollection RETURN u.num"
    end

    it "instantiate size" do
      myAQL = @database.new_aql query: "FOR u IN MyCollection RETURN u.num"
      myAQL.batch_size = 5
      expect(myAQL.batch_size).to eq 5
    end
  end

  context "#execute" do
    it "execute" do
      myAQL = @database.new_aql query: "FOR u IN MyCollection RETURN u.num"
      myAQL.batch_size = 5
      myAQL.execute
      expect(myAQL.result.length).to eq 5
    end

    it "execute next" do
      myAQL = @database.new_aql query: "FOR u IN MyCollection RETURN u.num"
      myAQL.batch_size = 5
      myAQL.execute
      myAQL.next
      expect(myAQL.result.length).to eq 5
    end

    it "execute 2" do
      result = @database.execute_aql query: "FOR u IN MyCollection RETURN u.num"
      expect(result.result.length).to eq 14
    end
  end

  context "#info" do
    it "explain" do
      myAQL = @database.new_aql query: "FOR u IN MyCollection RETURN u.num"
      myAQL.batch_size = 5
      expect(myAQL.explain[:cacheable]).to be true
    end

    it "parse" do
      myAQL = @database.new_aql query: "FOR u IN MyCollection RETURN u.num"
      myAQL.batch_size = 5
      expect(myAQL.parse[:parsed]).to be true
    end

    it "query_tracking_properties" do
      expect(@database.query_tracking_properties[:enabled]).to be true
    end

    it "running_queries" do
      expect(@database.running_queries.empty?).to be true
    end

    it "slow_queries" do
      expect(@database.slow_queries.empty?).to be true
    end
  end

  context "#delete" do
    it "stopSlow" do
      expect(@database.clear_slow_queries_list).to be true
    end

    it "kill" do
      error = nil
      myAQL = @database.new_aql query: "FOR u IN MyCollection RETURN u.num"
      begin
        myAQL.kill
      rescue Arango::ErrorDB => e
        error = e.error_num
      end
      expect(error.class).to be Integer
    end

    it "changeProperties" do
      result = @database.set_query_tracking_properties max_slow_queries: 65
      expect(result[:maxSlowQueries]).to eq 65
    end
  end

  context "opal support for functions" do
    it "can install opal" do
      @server.install_opal_module(@database)
      collection = @database.get_collection('_modules')
      expect(collection.name).to eq '_modules'
      document = collection.get_document({path: '/opal'})
      expect(document.content).to be_a String
      STDERR.puts "Size: #{document.content.size}"
    end

    it "can use opal" do
      # skip "works only sometimes"
      @server.install_opal_module(@database)
      @database.create_aql_function('RUBY::VERSION', code: <<~JAVASCRIPT
        function() {
          require('opal');
          return Opal.RUBY_VERSION;
        }
      JAVASCRIPT
      )
      result = @database.execute_query('RETURN RUBY::VERSION()')
      expect(result.result.first).to be_a String
      expect(result.result.first).to eq '2.5.3'
    end

    it "can execute opal" do
      # skip "works only sometimes"
      @server.install_opal_module(@database)
      @database.create_aql_function('RUBY::ADD') do
        1 + 1
      end
      result = @database.execute_query('RETURN RUBY::ADD()')
      expect(result.result.first).to eq 2
    end
  end
end
