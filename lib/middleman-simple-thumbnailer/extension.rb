#
# add resize_to param to image_tag to create thumbnails 
#
#
# Usage:
# = image_tag item.image, resize_to: '50x30', class: 'thumbnail'
#
module MiddlemanSimpleThumbnailer
  class Extension < Middleman::Extension

    def initialize(app, options_hash={}, &block)
      super
      app.after_build do |builder|
        MiddlemanSimpleThumbnailer::Image.all_objects.each do |image| 
          builder.say_status :create, "#{image.resized_img_path}"
          image.save!
        end
      end
    end

    helpers do

      def image_tag(path, options={})
        resize_to = options.delete(:resize_to)
        return super(path, options) unless resize_to

        image = MiddlemanSimpleThumbnailer::Image.new(path, self.config)
        image.resize!(resize_to)
        if environment == :development
          super("data:#{image.mime_type};base64,#{image.base64_data}", options)
        else
          super(image.resized_img_path, options)
        end
      end

    end
  end
end

::Middleman::Extensions.register(:middleman_simple_thumbnailer, MiddlemanSimpleThumbnailer::Extension)