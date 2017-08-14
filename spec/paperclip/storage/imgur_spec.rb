require 'active_record'
require 'paperclip-imgur'

class CreateUsers < ActiveRecord::Migration[5.1]
  self.verbose = false

  def change
    create_table :users do |t|
      t.attachment :avatar
    end
  end
end

describe Paperclip::Storage::Imgur do
  def set_options(options)
    stub_const(
      'User',
      Class.new(ActiveRecord::Base) do
        has_attached_file :avatar, {storage: :imgur}.merge(options)
      end
    )
  end

  before :all do
    ActiveRecord::Base.send(:include, Paperclip::Glue)

    FileUtils.rm_rf 'tmp'
    FileUtils.mkdir_p 'tmp'
    ActiveRecord::Base.establish_connection('sqlite3:///tmp/foo.sqlite3')
    CreateUsers.migrate(:up)
    Paperclip.options[:log] = false
  end

  after :all do
    CreateUsers.migrate(:down)
  end

  describe '#parse_credentials' do
    it 'should complain when providing unsuitable credentials' do
      set_options(imgur_credentials: 1)

      expect { User.new.avatar }.to raise_error ArgumentError
    end

    it 'should accept a properly formed hash' do
      set_options(imgur_credentials: {client_key: '1', client_secret: '2', access_token: '3', refresh_token: '4'})

      expect { User.new.avatar }.to_not raise_error
    end

    it 'should use config/imgur.yml under a Rails application if we left credentials blank' do
      stub_const(
        'Rails',
        Class.new {
          def self.env
            'testing'
          end
          def self.root
            Dir.pwd
          end
        }
      )
      set_options({})

      expect { User.new.avatar }.to_not raise_error
    end

    it 'should accept a file path' do
      set_options(imgur_credentials: "#{Dir.pwd}/config/imgur.yml")

      expect { User.new.avatar }.to_not raise_error
    end

    it 'should accept a file' do
      set_options(imgur_credentials: File.open("#{Dir.pwd}/config/imgur.yml", 'r'))

      expect { User.new.avatar }.to_not raise_error
    end
  end

  describe '#url' do
    before do
      User = Class.new(ActiveRecord::Base) { has_attached_file :avatar, storage: :imgur, imgur_credentials: {client_key: '1', client_secret: '2', access_token: '3', refresh_token: '4'} }
    end

    it "should return the missing image path if there's no image" do
      expect(User.new.avatar.url).to eq '/avatars/original/missing.png'
      expect(User.new.avatar.url(:random_size)).to eq '/avatars/random_size/missing.png'
    end

    it "should return Imgur's image paths if there's an image" do
      user = User.create(avatar_file_name: 'random_valid_hash')

      expect(user.avatar.url(:random_size)).to eq "http://i.imgur.com/random_valid_hash.jpg"
      expect(user.avatar.url(:small_square)).to eq "http://i.imgur.com/random_valid_hashs.jpg"
      expect(user.avatar.url(:large_thumbnail)).to eq "http://i.imgur.com/random_valid_hashl.jpg"
    end
  end
end
