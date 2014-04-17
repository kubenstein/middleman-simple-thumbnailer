# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-simple-thumbnailer/version"

Gem::Specification.new do |s|
  s.name        = "middleman-simple-thumbnailer"
  s.version     = MiddlemanSimpleThumbnailer::VERSION
  s.authors     = ["kubenstein"]
  s.email       = ["kubenstein@gmail.com"]
  s.homepage    = "https://github.com/kubenstein/middleman-simple-thumbnailer"
  s.summary     = %q{Middleman extension that allows you to create image thumbnails by providing resize_to option to image_tag helper}
  s.description = %q{Middleman extension that allows you to create image thumbnails by providing resize_to option to image_tag helper}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency("middleman", [">= 3.0.0"])
  s.add_runtime_dependency("mini_magick")
end
