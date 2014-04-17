#
# add resize_to param to image_tag to create thumbnails 
#
#
# Usage:
# = image_tag item.image, resize_to: '50x30', class: 'center'
#
module MiddlemanSimpleThumbnailer
  class Extension < Middleman::Extension
    def initialize(app, options_hash={}, &block)
      app.helpers do


        def image_tag(path, options={})
          resize_to = options.delete(:resize_to)
          return super(path, options) unless resize_to

          # config variables
          middleman_settings = self.config
          images_dir = middleman_settings[:images_dir]
          build_dir = middleman_settings[:build_dir]

          # image paths variables
          image_basename = File.basename(path)
          new_image_basename = image_basename.split('.').tap { |a| a.insert(-2, resize_to) }.join('.')
          new_image_path = path.gsub(image_basename, new_image_basename)

          # resize
          image = Magick::Image.read("./source/#{images_dir}/#{path}").first
          image.change_geometry!(resize_to) { |cols, rows, img| img.resize!(cols, rows) }

          # rendering
          if middleman_settings.environment == :development
            data = Base64.encode64(image.to_blob)
            super("data:#{image.mime_type};base64,#{data}", options)
          else
            image.write("./#{build_dir}/#{images_dir}/#{new_image_path}")
            super(new_image_path, options)
          end
        end


      end
      super
    end
  end
end

::Middleman::Extensions.register(:middleman_simple_thumbnailer, MiddlemanSimpleThumbnailer::Extension)