Middleman Simple Thumbnailer [![Build Status](https://travis-ci.org/kubenstein/middleman-simple-thumbnailer.png?branch=master)](https://travis-ci.org/kubenstein/middleman-simple-thumbnailer)
=============

Middleman Simple Thumbnailer is a [Middleman](http://middlemanapp.com/) extension that allows you to create image thumbnails by providing `resize_to` option to image_tag helper.


Installation
-------
Put this line into your `Gemfile`:
```
gem 'middleman-simple-thumbnailer'
```

Usage
-----
Enable the extension in `config.rb`:
```
activate :middleman_simple_thumbnailer
```

And modify your `image_tag`'s by adding `resize_to` parameter:
```
= image_tag image, resize_to: '50x50', class: 'thumbnail'
```

You can also use the `image_path` helper the same way in place where you need only the path of the resized image:
```
<picture>
  <source srcset="<%= image_path "original.jpg", resize_to: 1200 %>" media="(min-width: 900px)">
  <%= image_tag "original.jpg", resize_to: "400%", class: 'the-image-class' %>
</picture>
``` 

This extension use ImageMagick (via mini_magick) to resize the images.
The `resize_to` format is therefore the one defined ny ImageMagick. The documentation can be found [there](http://www.imagemagick.org/script/command-line-processing.php#geometry).

Build/Development modes
-----
  During development thumbnails will be created on fly and presented as a base64 strings.
  During build thumbnails will be created as normal files and stored in same dir as their originals.

LICENSE
-----
MIT