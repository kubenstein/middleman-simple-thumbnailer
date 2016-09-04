module MiddlemanSimpleThumbnailer

  class ImageStore

    attr_reader :tmp_path

    def initialize
      @tmp_path =  Dir::Tmpname.create('thumbnail', nil) {}
    end

    def store(img_path, resize_to)
      File.open(@tmp_path, File::RDWR|File::CREAT, 0644) do |f|
        f.flock(File::LOCK_EX)
        resized_images = f.size > 0 ? Marshal.load(f) : {}
        file_key = "#{img_path}.#{resize_to}"
        if ! resized_images.has_key?(file_key)
          resized_images[file_key] = [img_path, resize_to]
          f.rewind
          Marshal.dump(resized_images,f)
          f.flush
          f.truncate(f.pos)
        end
      end
    end

    def each
      File.open(@tmp_path, "r") do |f|
        f.flock(File::LOCK_SH)
        resized_images = f.size > 0 ? Marshal.load(f) : {}
        resized_images.values.each do |store_entry|
          yield *store_entry
        end
      end
    end

    def delete
      File.delete(@tmp_path)
    end

  end
end
