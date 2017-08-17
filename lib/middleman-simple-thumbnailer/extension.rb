require 'tmpdir'
require 'yaml'
require 'json'
require 'tempfile'
# add resize_to param to image_tag to create thumbnails
#
#
# Usage:
# = image_tag item.image, resize_to: '50x30', class: 'thumbnail'
#
module MiddlemanSimpleThumbnailer
  class Extension < Middleman::Extension

    option :cache_dir, 'tmp/simple-thumbnailer-cache', 'Directory (relative to project root) for cached thumbnails.'
    option :use_specs, false, 'Wether or not use the specification data file'
    option :specs_data, 'simple_thumbnailer', 'name of the specification data file. Must follow middleman data file name convention'
    option :specs_data_default_format, 'yaml', 'defaut specification file format (and extension). Can be yaml, yml or json'
    option :specs_data_save_old, true, 'save previous specification data file '
    option :update_specs, true, 'Warn about missing image file in specification and add them to teh spec file'

    def initialize(app, options_hash={}, &block)
        super
        @images_store = MiddlemanSimpleThumbnailer::ImageStore.new
        @resize_specs = app.data[options.specs_data] || []
        if @resize_specs.length == 0
          @resize_specs = []
        end
        if !%w(yaml yml json).include?(options.specs_data_default_format)
          raise "value assigned to option specs_data_default_format is not correct. should be one of json, yaml, or yml"
        end
    end

    def store_resized_image(img_path, resize_to)
      @images_store.store(img_path, resize_to)
    end

    # def after_configuration
    #   MiddlemanSimpleThumbnailer::Image.options = options
    # end

    def check_image_in_specs(img_path, resize_to)
      @resize_specs.each do |resize_spec|
        if resize_to == resize_spec.resize_to && File.fnmatch(resize_spec.path, img_path)
          return true
        end
      end
      return false
    end


    # def source_dir
    #   File.absolute_path(app.config[:source], app.root)
    # end


    def manipulate_resource_list(resources)
      return resources unless options.use_specs
      resources + @resize_specs.reduce([]) do |res, resize_spec|
        Dir.chdir(File.absolute_path(File.join(app.root, app.config[:source], app.config[:images_dir]))) do
          Dir.glob(resize_spec.path) do |image_file|
            store_resized_image(image_file, resize_spec.resize_to)
            img = MiddlemanSimpleThumbnailer::Image.new(image_file, resize_spec.resize_to, app, options).tap do |i|
              i.prepare_thumbnail
            end
            resized_image_path = File.join(app.config[:images_dir],img.resized_img_path)
            new_resource = MiddlemanSimpleThumbnailer::Resource.new(
              app.sitemap,
              resized_image_path,
              img.cached_resized_img_abs_path,
            )
            res.push(new_resource)
          end
        end
        res
      end
    end

    def after_build(builder)
      resize_specs_modified = false
      @images_store.each do |img_path, resize_to|
        if options.use_specs && options.update_specs && !check_image_in_specs(img_path, resize_to)
          builder.thor.say_status :warning, "#{img_path}:#{resize_to} not in resize spec", :yellow
          @resize_specs.push(Middleman::Util::EnhancedHash.new({'path': img_path, 'resize_to': resize_to}))
          resize_specs_modified = true
        end
        img = MiddlemanSimpleThumbnailer::Image.new(img_path, resize_to, builder.app, options)
        if !File.exists?(img.resized_img_abs_path)
          builder.thor.say_status :create, "#{img.resized_img_abs_path}"
          img.save!
        end
      end
      @images_store.delete
      if options.update_specs && resize_specs_modified
        builder.thor.say_status :warning, "Resize specs modified, rewrite", :yellow
        write_specs_file
      end
    end

    def get_data_file_path_ext
      specs_data_list = Dir.glob(File.absolute_path(File.join(app.root, app.config[:data_dir],"#{options.specs_data}.{json,yml,yaml}")))
      if specs_data_list.length > 0
        return specs_data_list[0], File.extname(specs_data_list[0])[1..-1]
      else
        return File.absolute_path(File.join(app.root, app.config[:data_dir],"#{options.specs_data}.#{options.specs_data_default_format}")), options.specs_data_default_format
      end
    end

    def write_specs_file
      data_file, ext = get_data_file_path_ext
      FileUtils.mkdir_p File::dirname(data_file)
      if File.exists?(data_file) && options.specs_data_save_old
        i = 1
        old_data_file = "#{data_file}.#{i}"
        while File.exists?(old_data_file) && (i+=1) < ((2**16)-1)
          old_data_file = "#{data_file}.#{i}"
        end
        raise "Middleman-simple-thumbnailer : could not find a filename for saving the data file " if i == ((2**16)-1)
        FileUtils.cp(data_file, old_data_file)
      end
      new_specs = @resize_specs.map do |resize_spec|
        resize_spec.to_hash
      end
      File.open(data_file, 'w') {|f| f.write ((%w(yaml yml).include?(ext))?new_specs.to_yaml():JSON.pretty_generate(new_specs)) }
    end


    private :check_image_in_specs, :get_data_file_path_ext, :write_specs_file

    helpers do

      def resized_image_path(path, resize_to=nil)
        return path unless resize_to

        ext = app.extensions[:middleman_simple_thumbnailer]

        image = MiddlemanSimpleThumbnailer::Image.new(path, resize_to, app, ext.options)
        if app.development?
          "data:#{image.mime_type};base64,#{image.base64_data}"
        else
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
