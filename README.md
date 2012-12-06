# Paperclip::Imgur

This gem extends [Paperclip](https://github.com/thoughtbot/paperclip) with [Imgur](http://imgur.com/) storage.
If you want Paperclip Dropbox support, have a look at this [great gem](https://github.com/janko-m/paperclip-dropbox/).

## Installation

First of all, install my [Imgur API gem](https://github.com/dncrht/imgur).

Clone this project, build the gem and install it:
 
```bash
    $ git clone https://github.com/dncrht/paperclip-imgur.git
    $ cd paperclip-imgur
    $ gem build paperclip-imgur.gemspec
    $ gem install paperclip-imgur
```

Alternatively, you can add this line to your application's Gemfile:
```ruby
    gem 'paperclip-imgur', :git => 'git://github.com/dncrht/paperclip-imgur.git'
```

And then execute:
```bash
    $ bundle install
```

## Usage

A typical model:
```ruby
    class User < ActiveRecord::Base
      has_attached_file :avatar, :storage => :imgur
    end
```

It will search for a file in "#{Rails.root}/config/imgur.yml". This file should contain your credentials:
```yml
app_key: "YOUR_APPLICATION_KEY"
app_secret: "YOUR_APPLICATION_SECRET"
access_token: "YOUR_ACCESS_TOKEN"
access_token_secret: "YOUR_ACCESS_TOKEN_SECRET"
```

You can also specify the credentials per model attribute, using a hash:
```ruby
      has_attached_file :avatar, :storage => :imgur, :imgur_credentials => {:app_key => 'YOUR_APPLICATION_KEY', :app_secret => 'YOUR_APPLICATION_SECRET', :access_token => 'YOUR_ACCESS_TOKEN', :access_token_secret => 'YOUR_ACCESS_TOKEN_SECRET'}
```
...or path to a YAML file
```ruby
      has_attached_file :avatar, :storage => :imgur, :imgur_credentials => 'path.to/file.yml'
```
...or a File itself
```ruby
      has_attached_file :avatar, :storage => :imgur, :imgur_credentials => File.open('path.to/file.yml', 'r')
```

The image is available in your views, in three different sizes:
```ruby
    <%= image_path @user.avatar %>
    <%= image_path @user.avatar.url(:small_square) %>
    <%= image_path @user.avatar.url(:large_thumbnail) %>
```

