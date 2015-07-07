# Paperclip::Imgur

This gem extends [Paperclip](https://github.com/thoughtbot/paperclip) with [Imgur](http://imgur.com/) storage. It's been tested with Paperclip 3.3.1 and 4.3.

If you want Paperclip Dropbox support, have a look at this [great gem](https://github.com/janko-m/paperclip-dropbox/).

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'paperclip-imgur'
```

And then run:
```bash
$ bundle install
```

## Usage

Tell your typical model™ to use Imgur as storage:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar, storage: :imgur
end
```

### Credentials

The credentials to upload and delete images from Imgur will be read from `#{Rails.root}/config/imgur.yml`. This file must contain the following keys:
```yml
client_id: 'CLIENT_ID'
client_secret: 'CLIENT_SECRET'
refresh_token: 'REFRESH_TOKEN'
```

Get these keys with:
```bash
rake imgur:authorize CLIENT_ID='CLIENT_ID' CLIENT_SECRET='CLIENT_SECRET'
```
Please refer to the [API client gem documentation](https://github.com/dncrht/imgur) for more information on this.

You can also specify the credentials per model attribute, using a hash:
```ruby
has_attached_file :avatar, storage: :imgur, imgur_credentials: {client_id: 'CLIENT_ID', client_secret: 'CLIENT_SECRET', refresh_token: 'REFRESH_TOKEN'}
```
…or path to a YAML file
```ruby
has_attached_file :avatar, storage: :imgur, imgur_credentials: 'path.to/file.yml'
```
…or a File itself
```ruby
has_attached_file :avatar, storage: :imgur, imgur_credentials: File.open('path.to/file.yml', 'r')
```

### Use attachment in views

The image is available in your views in three different sizes:
```ruby
<%= image_path @user.avatar %>
<%= image_path @user.avatar.url(:small) %>
<%= image_path @user.avatar.url(:large) %>
```

### Deleting images

To delete an image, follow the usual Paperclip procedure:
```ruby
@user.avatar = nil
@user.save
```

## Testing

Run specs with
```bash
rspec
```
