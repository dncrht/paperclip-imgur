require 'yaml'
require 'erb'

module Paperclip
  module Storage
    module Imgur
      def self.extended(base)
        begin
          require 'imgur'
        rescue LoadError => e
          e.message << " (You may need to install the imgur gem from dncrht's github)"
          raise e
        end unless defined?(::Imgur)

        base.instance_eval do
          imgur_credentials = parse_credentials(@options[:imgur_credentials])
          imgur_options = @options[:imgur_options] || {}
          environment = defined?(Rails) ? Rails.env : imgur_options[:environment].to_s
          imgur_credentials = (imgur_credentials[environment] || imgur_credentials).symbolize_keys # Read credentials from the current Rails environment, if any
          imgur_session(imgur_credentials)
        end
      end

      # We have to trust that any Imgur hash stored into *_file_name represents an existing Imgur image.
      # This assumption let us avoid the latency of a network call.
      # If not, someone has touched where he shouldn't!
      def exists?(style_name = default_style)
        if original_filename
          true
        else
          false
        end
      end

      def flush_writes
        @queued_for_write.each do |style, file| #style is 'original' etc...

          begin
            image = @imgur_session.image.image_upload(file)
            image_id = image.id
          rescue
            # Sometimes there are API or network errors.
            # In this cases, we don't store anything.
            image_id = nil
          end

          # What? update_column? Yes...
          # ...we cannot use update_attribute because it internally calls save, and save calls flush_writes again, and it will end up in a stack overflow due excessive recursion
          instance.update_column :"#{name}_#{:file_name}", image_id
        end
        after_flush_writes
        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          @imgur_session.image.image_delete(path) # Doesn't matter if the image doesn't really exists
        end
        @queued_for_delete = []
      end

      # Returns the image's URL.
      # We don't use imgur_session.find to avoid the latency of a network call.
      def url(size = default_style)
        image_id = instance.send("#{name}_#{:file_name}")

        return @url_generator.for(size, {}) if image_id.blank? # Paperclip's default missing image path

        ::Imgur::Image.new(id: image_id).url(size)
      end

      # Returns the path of the attachment.
      # It's exactly the Imgur hash.
      def path(style_name = default_style)
        original_filename
      end

      def copy_to_local_file(style, destination_path)
        # TO BE DONE
        #local_file = File.open(destination_path, 'wb')
        #local_file.write(imgur_session.get_file(path(style)))
        #local_file.close
      end

      #private

      def imgur_session(imgur_credentials)
        @imgur_session = ::Imgur::Session.new(imgur_credentials)
      end

      def parse_credentials(credentials = nil)
        if credentials.nil? and defined?(Rails) and File.exists?("#{Rails.root}/config/imgur.yml")
          credentials = "#{Rails.root}/config/imgur.yml"
        end

        result =
          case credentials
        when File
          YAML.load(ERB.new(File.read(credentials.path)).result)
        when String, Pathname
          YAML.load(ERB.new(File.read(credentials)).result)
        when Hash
          credentials
        else
          raise ArgumentError, ":imgur_credentials are not a path, file, nor a hash"
        end

        result.stringify_keys
      end
    end
  end
end
