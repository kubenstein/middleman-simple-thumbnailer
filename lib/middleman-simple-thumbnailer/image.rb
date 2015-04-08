require "digest"
require 'fileutils'

module MiddlemanSimpleThumbnailer
  class Image
    @@all_objects = []
    @@options = nil

    attr_accessor :img_path, :middleman_config, :resize_to

    def initialize(img_path, middleman_config)
      @@all_objects << self

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
      Base64.encode64(File.read(cached_resized_img_abs_path))
    end

    def resize!(resize_to)
      self.resize_to = resize_to
      return if cached_thumbnail_available?
      image.resize(resize_to)
      save_cached_thumbnail
    end

    def save!
      if cached_thumbnail_available?
        FileUtils.cp cached_resized_img_abs_path, resized_img_abs_path
      else
        image.write(resized_img_abs_path)
      end
    end

    def self.all_objects
      @@all_objects
    end

    def self.options=(options)
      @@options = options
    end
    
    
    private

    def image
      @image ||= MiniMagick::Image.open(abs_path)
    end

    def image_checksum
      @image_checksum ||= Digest::SHA2.file(abs_path).hexdigest[0..16]
    end

    def image_name
      File.basename(abs_path)
    end

    def resized_image_name
      image_name.split('.').tap { |a| a.insert(-2, resize_to) }.join('.') # add resize_to sufix
          .gsub(/[%@!<>^]/, '>' => 'gt', '<' => 'lt', '^' => 'c')                     # sanitize file name
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

    def cached_resized_img_abs_path
      File.join(cache_dir, middleman_abs_path).gsub(image_name, resized_image_name).split('.').tap { |a|
        a.insert(-2, image_checksum)
      }.join('.')
    end
    
    def cached_thumbnail_available?
      File.exist?(cached_resized_img_abs_path)
    end
   
    def save_cached_thumbnail
      FileUtils.mkdir_p(File.dirname(cached_resized_img_abs_path))
      image.write(cached_resized_img_abs_path)
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

    def cache_dir
      @@options.cache_dir
    end
  end
end