require 'tmpdir'
require_relative 'image_store'#
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
      @images_store.each do |img_entry|
        img = MiddlemanSimpleThumbnailer::Image.new(img_entry.img_path, img_entry.resize_to, builder.app)
        builder.thor.say_status :create, "#{img.resized_img_abs_path}"
        img.save!
      end
      @images_store.delete
    end

    helpers do

      def image_tag(path, options={})
        resize_to = options.delete(:resize_to)
        return super(path, options) unless resize_to

        image = MiddlemanSimpleThumbnailer::Image.new(path, resize_to, app)
        if app.development?
          super("data:#{image.mime_type};base64,#{image.base64_data}", options)
        else
          ext = app.extensions[:middleman_simple_thumbnailer]
          ext.store_resized_image(path, resize_to)
          super(image.resized_img_path, options)
        end
      end

    end

  end
end

::Middleman::Extensions.register(:middleman_simple_thumbnailer, MiddlemanSimpleThumbnailer::Extension)
