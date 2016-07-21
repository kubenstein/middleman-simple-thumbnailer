#
# add resize_to param to image_tag to create thumbnails
#
#
# Usage:
# = image_tag item.image, resize_to: '50x30', class: 'thumbnail'
#
module MiddlemanSimpleThumbnailer
  class Extension < Middleman::Extension

    option :cache_dir, 'tmp/simple-thumbnailer-cache', 'Directory (relative to project root) for cached thumbnails.'

    attr_reader :resized_images

    def initialize(app, options_hash={}, &block)
      super
      @resized_images = {}
    end

    def after_configuration
      MiddlemanSimpleThumbnailer::Image.options = options
    end

    def after_build(builder)
      @resized_images.values.each do |img|
        builder.thor.say_status :create, "#{img.resized_img_abs_path}"
        img.save!
      end
    end

    helpers do

      def image_tag(path, options={})
        resize_to = options.delete(:resize_to)
        return super(path, options) unless resize_to

        image = MiddlemanSimpleThumbnailer::Image.new(path, resize_to, self.config)
        if app.development?
          super("data:#{image.mime_type};base64,#{image.base64_data}", options)
        else
          ext = app.extensions[:middleman_simple_thumbnailer]
          ext.resized_images.store(image.resized_img_path, image)
          super(image.resized_img_path, options)
        end
      end

    end

  end
end

::Middleman::Extensions.register(:middleman_simple_thumbnailer, MiddlemanSimpleThumbnailer::Extension)
