Middleman Simple Thumbnailer 
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
```
= image_tag image, resize_to: '50x50', class: 'thumbnail'
```

Build/Development modes
-----
  During development thumbnails will be created on fly and presented as a base64 strings.
  During build thumbnails will be created as normal files and stored in same dir as their originals.

TODO
-----
  - add caching mechanizm in development mode
  - add tests
