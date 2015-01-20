require 'spec_helper'

describe Anyway::Config do
  let(:conf) { CoolConfig.new }
  let(:test_conf) { Anyway::TestConfig.new }

  describe "config with name" do
    specify { expect(CoolConfig.config_name).to eq "cool" }
    
    describe "defaults" do
      specify { expect(CoolConfig.defaults[:port]).to eq 8080 }
      specify { expect(CoolConfig.defaults[:host]).to eq 'localhost' }
    end

    specify do
      expect(conf).to respond_to(:meta)
      expect(conf).to respond_to(:data)
      expect(conf).to respond_to(:port)
      expect(conf).to respond_to(:host)
      expect(conf).to respond_to(:user)
    end

    describe "load from files" do
      it "should set defauls" do 
        expect(conf.port).to eq 8080
      end

      it "should load config from YAML" do
        expect(conf.host).to eq "test.host"
      end

      unless Rails.application.try(:secrets).nil?
        it "should load config from secrets" do
          expect(conf.user[:name]).to eq "test"
          expect(conf.user[:password]).to eq "test"   
        end
      else
        it "should load config from file if no secrets" do
          expect(conf.user[:name]).to eq "root"
          expect(conf.user[:password]).to eq "root"   
        end
      end
    end

    describe "load from env" do
      after(:each) { Anyway.env.clear }
      it "should work" do
        ENV['COOL_PORT'] = '80'
        ENV['COOL_USER__NAME'] = 'john'
        Anyway.env.reload
        expect(conf.port).to eq '80'
        expect(conf.user[:name]).to eq 'john'
      end
    end

    describe "clear" do
      let(:conf_cleared) { conf.clear }

      specify do
        expect(conf_cleared.meta).to be_nil
        expect(conf_cleared.data).to be_nil
        expect(conf_cleared.host).to be_nil
        expect(conf_cleared.user).to be_nil
        expect(conf_cleared.port).to be_nil
      end
    end

    describe "reload" do
      after(:each) { Anyway.env.clear }
      it do
        expect(conf.port).to eq 8080
        ENV['COOL_PORT'] = '80'
        ENV['COOL_USER__NAME'] = 'john'
        Anyway.env.reload
        conf.reload
        expect(conf.port).to eq '80'
        expect(conf.user[:name]).to eq 'john'
      end
    end
  end

  describe "config with default name" do
    after(:each) { Anyway.env.clear }
    specify { expect(Anyway::TestConfig.config_name).to eq "anyway" }

    specify do
      expect(test_conf).to respond_to(:test)
      expect(test_conf).to respond_to(:api)
    end

    it "should work" do
      ENV['ANYWAY_API__KEY'] = 'test1'
      ENV['ANYWAY_TEST'] = 'test'
      Anyway.env.reload
      expect(test_conf.api[:key]).to eq "test1"
      expect(test_conf.test).to eq "test"
    end
  end
end