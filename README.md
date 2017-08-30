Middleman Simple Thumbnailer [![Build Status](https://travis-ci.org/kubenstein/middleman-simple-thumbnailer.png?branch=master)](https://travis-ci.org/kubenstein/middleman-simple-thumbnailer)
=============

Middleman Simple Thumbnailer is a [Middleman](http://middlemanapp.com/) extension that allows you to create image thumbnails by providing `resize_to` option to image_tag helper.


## Installation

Put this line into your `Gemfile`:
```
gem 'middleman-simple-thumbnailer'
```

## Usage

### All mode

Enable the extension in `config.rb`:
```ruby
activate :middleman_simple_thumbnailer
```

And modify your `image_tag`'s by adding `resize_to` parameter:
```
= image_tag image, resize_to: '50x50', class: 'thumbnail'
```

You can also use the `image_path` helper the same way in place where you need only the path of the resized image:
```html
<picture>
  <source srcset="<%= image_path 'original.jpg', resize_to: 1200 %>" media="(min-width: 900px)">
  <%= image_tag "original.jpg", resize_to: "400%", class: 'the-image-class' %>
</picture>
``` 

This extension use ImageMagick (via mini_magick) to resize the images.
The `resize_to` format is therefore the one defined ny ImageMagick. The documentation can be found [there](http://www.imagemagick.org/script/command-line-processing.php#geometry).

### Dynamic mode

This mode is the default operating mode for this extension.
The images are generated according to their declaration in the helpers.
See the [known limitations](#known-limitation) paragraph below for known limitation in this mode.

### Declarative mode

In this mode, the resized file are declared. They are then added to the sitemap and generated at the same time than the other files.

To activate this new mode, the option `:use_specs` must be used when activating the extension.

```ruby
activate :middleman_simple_thumbnailer, use_specs: true
```

Then the resizing specifications must be declared in a special [Middleman data file](https://middlemanapp.com/advanced/data-files/). By default the extension will look for `data/simple_thumbnailer.yaml`.

This file must contains a list of mappings with the following keys:
  - `path`: the relative path of the image file in the `source\images` folder. This can be a glob pattern (https://ruby-doc.org/core/Dir.html#method-c-glob) (still relative to the `source\images` folder).
  - `resize_to`: the [ImageMagix resize](http://www.imagemagick.org/script/command-line-processing.php#geometry) parameter

example (in yaml, file `data/simple_thumbnailer.yaml`):

```yaml
---
- path: original.jpg
  resize_to: 10x10
- path: "*.jpg"
  resize_to: 5x5
```

The use of the `image_tag` and `image_path` helpers stay the same.

In this mode if a resizing specification found in an `image_tag` or `image_path` helper is not declared in the specification data file, a warning is emitted and the data file is rewritten to include the resizing specification. If the specification file doesn't exist, it is created (this behavior can be configured).


### options

Option                        | default value                    | Description 
------------------------------|----------------------------------|-------------
:cache_dir                    | `'tmp/simple-thumbnailer-cache'` | Directory (relative to project root) for cached thumbnails.
:use_specs                    | `false`                          | Wether or not use resize specfication data file
:specs\_data                  | `'simple_thumbnailer'`           | name of the specification data file. It must follow the Middleman data file name convention.
:specs\_data\_default\_format | `'yaml'`                         | defaut specification format (and extension). Can be 'yml', 'yaml', 'json'
:specs\_data\_save\_old       | `true`                           | save previous specification data file
:update\_specs                | `true`                           | Warn about missing image files in the specification file and add them to it. The spécification file will be overwritten.


## Known limitation

In the dynamic mode, this extension is unable to update the [sitemap](https://middlemanapp.com/advanced/sitemap/). Some extensions (like [middleman-s3_sync](https://github.com/fredjean/middleman-s3_sync)) uses the content of the sitemap to do their work. Therefore, the generated resized images will not be seen by such extensions, even if they are corectly generated.


## Build/Development modes

During development thumbnails will be created when accessed. They are served with a rack middleware from the cache folder.

During build thumbnails will be created as normal files and stored in same dir as their originals.


## LICENSE

MIT
