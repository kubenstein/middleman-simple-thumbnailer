module MiddlemanSimpleThumbnailer
  class Resource < ::Middleman::Sitemap::Resource
    def initialize(store, path, source)
      super(store, path, source)
    end

    def ignored?
      false
    end

    def template?
      false
    end

    def binary?
      true
    end
  end
end
