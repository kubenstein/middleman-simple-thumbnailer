require 'tmpdir'
# add resize_to param to image_tag to create thumbnails
#
#
# Usage:
# = image_tag item.image, resize_to: '50x30', class: 'thumbnail'
#
module MiddlemanSimpleThumbnailer
  class Extension < Middleman::Extension

    option :cache_dir, 'tmp/simple-thumbnailer-cache', 'Directory (relative to project root) for cached thumbnails.'

    def initialize(app, options_hash={}, &block)
        super
        @images_store = MiddlemanSimpleThumbnailer::ImageStore.new
    end

    def store_resized_image(img_path, resize_to)
      @images_store.store(img_path, resize_to)
    end

    def after_configuration
      MiddlemanSimpleThumbnailer::Image.options = options
    end

    def after_build(builder)
      @images_store.each do |img_path, resize_to|
        img = MiddlemanSimpleThumbnailer::Image.new(img_path, resize_to, builder.app)
        builder.thor.say_status :create, "#{img.resized_img_abs_path}"
        img.save!
      end
      @images_store.delete
    end

    helpers do

      def resized_image_path(path, resize_to=nil)
        return path unless resize_to

        image = MiddlemanSimpleThumbnailer::Image.new(path, resize_to, app)
        if app.development?
          "data:#{image.mime_type};base64,#{image.base64_data}"
        else
          ext = app.extensions[:middleman_simple_thumbnailer]
          ext.store_resized_image(path, resize_to)
          image.resized_img_path
        end
      end

      def image_tag(path, options={})
        resize_to = options.delete(:resize_to)
        new_path = resize_to ? resized_image_path(path, resize_to) : path
        super(new_path, options)
      end

      def image_path(path, options={})
        resize_to = options.delete(:resize_to)
        new_path = resize_to ? resized_image_path(path, resize_to) : path
        super(new_path)
      end
    
    end

  end
end

::Middleman::Extensions.register(:middleman_simple_thumbnailer, MiddlemanSimpleThumbnailer::Extension)
