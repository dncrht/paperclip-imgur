require 'paperclip-imgur'
require 'active_record'

class CreateUsers < ActiveRecord::Migration
  self.verbose = false

  def change
    create_table :users do |t|
      t.attachment :avatar
    end
  end
end

describe Paperclip::Storage::Imgur do
  before(:all) do
    ActiveRecord::Base.send(:include, Paperclip::Glue)

    FileUtils.rm_rf 'tmp'
    FileUtils.mkdir_p 'tmp'
    ActiveRecord::Base.establish_connection('sqlite3:///tmp/foo.sqlite3')
    CreateUsers.migrate(:up)

    Paperclip.options[:log] = false
  end
  
  describe '#parse_credentials' do
    def set_options(options)
      stub_const('User', Class.new(ActiveRecord::Base) {
          has_attached_file :avatar, { :storage => :imgur }.merge(options)
        })
    end

    it 'should complain when providing unsuitable credentials' do
      set_options(:imgur_credentials => 1)
      expect { User.new.avatar }.to raise_error

      set_options(:imgur_credentials => {})
      expect { User.new.avatar }.to raise_error
    end
    
    it 'should accept a properly formed hash' do
      set_options(:imgur_credentials => {:app_key => '1', :app_secret => '2', :access_token => '3', :access_token_secret => '4'})
      expect { User.new.avatar }.to_not raise_error
    end

    it 'should use config/imgur.yml under a Rails application if we left credentials blank' do
      stub_const('Rails', Class.new {
          def self.env
            'testing'
          end
          def self.root
            Dir.pwd
          end
        })

      set_options({})
      expect { User.new.avatar }.to_not raise_error
    end
    
    it 'should accept a file path' do
      set_options(:imgur_credentials => "#{Dir.pwd}/config/imgur.yml")
      expect { User.new.avatar }.to_not raise_error
    end
    
    it 'should accept a file' do
      set_options(:imgur_credentials => File.open("#{Dir.pwd}/config/imgur.yml", 'r'))
      expect { User.new.avatar }.to_not raise_error
    end
  end
  
  describe '#url' do
    before(:each) do
      stub_const('User', Class.new(ActiveRecord::Base) { has_attached_file :avatar, :storage => :imgur, :imgur_credentials => {:app_key => '1', :app_secret => '2', :access_token => '3', :access_token_secret => '4'} })

      @imgur_hash = 'random_valid_hash'
      @user = User.create(:avatar_file_name => @imgur_hash)
    end

    it "should return the missing image path if there's no image" do
      User.new.avatar.url.should eq('/avatars/original/missing.png')
      User.new.avatar.url(:random_size).should eq('/avatars/random_size/missing.png')
    end

    it "should return Imgur's image paths if there's an image" do
      session = @user.avatar.instance_variable_get(:@imgur_session)
      
      @user.avatar.url.should eq(session.url(@imgur_hash))
      @user.avatar.url(:random_size).should eq(session.url(@imgur_hash, :random_size))
      @user.avatar.url(:small_square).should eq(session.url(@imgur_hash, :small_square))
      @user.avatar.url(:large_thumbnail).should eq(session.url(@imgur_hash, :large_thumbnail))
    end
    
  end
  
end