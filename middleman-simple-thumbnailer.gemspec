# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'middleman-simple-thumbnailer/version'

Gem::Specification.new do |s|
  s.name        = 'middleman-simple-thumbnailer'
  s.version     = MiddlemanSimpleThumbnailer::VERSION
  s.authors     = ['Jakub Niewczas']
  s.email       = ['niewczas.jakub@gmail.com']
  s.homepage    = 'https://github.com/kubenstein/middleman-simple-thumbnailer'
  s.license     = 'MIT'
  s.summary     = %q{Middleman extension that allows you to create image thumbnails by providing resize_to option to image_tag helper}
  s.description = %q{Middleman extension that allows you to create image thumbnails by providing resize_to option to image_tag helper}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {fixtures,features}/*`.split("\n")
  s.require_paths = ['lib']
  
  s.add_runtime_dependency 'middleman-core', '~> 3'
  s.add_runtime_dependency 'mini_magick', '~> 4'

  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'aruba', '~>0.5.4'
  s.add_development_dependency 'cucumber', '~> 1.3'
end
