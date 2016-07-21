require 'tmpdir'

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

    def initialize(app, options_hash={}, &block)
      super
      @tmp_path = Dir::Tmpname.create('thumbnail', nil) {}
    end

    def store_resized_image(img_path, resize_to)
      File.open(@tmp_path, File::RDWR|File::CREAT, 0644) { |f|
        f.flock(File::LOCK_EX)
        resized_images = f.size > 0 ? Marshal.load(f) : {}
        resized_images["#{img_path}.#{resize_to}"] = [img_path, resize_to]
        f.rewind
        Marshal.dump(resized_images,f)
        f.flush
        f.truncate(f.pos)
      }
    end

    def after_configuration
      MiddlemanSimpleThumbnailer::Image.options = options
    end

    def after_build(builder)
      File.open(@tmp_path, "r") {|f|
        f.flock(File::LOCK_SH)
        resized_images = Marshal.load(f)
        resized_images.values.each do |img_array|
          img = MiddlemanSimpleThumbnailer::Image.new(img_array[0], img_array[1], builder.app.config)
          builder.thor.say_status :create, "#{img.resized_img_abs_path}"
          img.save!
        end
      }
      File.delete(@tmp_path)
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
          ext.store_resized_image(path, resize_to)
          super(image.resized_img_path, options)
        end
      end

    end

  end
end

::Middleman::Extensions.register(:middleman_simple_thumbnailer, MiddlemanSimpleThumbnailer::Extension)
