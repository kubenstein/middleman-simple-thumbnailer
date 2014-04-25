module MiddlemanSimpleThumbnailer
  class Image
    attr_accessor :img_path, :middleman_config, :resize_to

    def initialize(img_path, middleman_config)
      @img_path = img_path
      @middleman_config = middleman_config
    end

    def mime_type
      image.mime_type
    end

    def resized_img_path
      img_path.gsub(image_name, resized_image_name)
    end

    def base64_data
      Base64.encode64(image.to_blob)
    end

    def resize!(resize_to)
      self.resize_to = resize_to
      image.resize(resize_to)
    end

    def save!
      image.write(resized_img_abs_path)
    end

    
    private

    def image
      @image ||= MiniMagick::Image.open(abs_path)
    end

    def image_name
      File.basename(abs_path)
    end

    def resized_image_name
      image_name.split('.').tap { |a| a.insert(-2, resize_to) }.join('.')      
    end

    def abs_path
      File.join(source_dir, middleman_abs_path)
    end

    def middleman_abs_path
      img_path.start_with?('/') ? img_path : File.join(images_dir, img_path) 
    end

    def resized_img_abs_path
      File.join(build_dir, middleman_abs_path).gsub(image_name, resized_image_name)
    end

    def source_dir
      middleman_config[:source]
    end

    def images_dir
      middleman_config[:images_dir]
    end

    def build_dir
      middleman_config[:build_dir]
    end

  end
end