require 'yaml'
require 'uri'

Given(/^there is no cache directory yet$/) do
  if directory? MiddlemanSimpleThumbnailer::Extension.config.cache_dir
    remove MiddlemanSimpleThumbnailer::Extension.config.cache_dir
  end
end


Then(/^the cache directory should exist (?:at "([^"]+)" )?with the following files$/) do |cache_dir, files|
  cache_dir ||= MiddlemanSimpleThumbnailer::Extension.config.cache_dir
  expect(cache_dir).to be_an_existing_directory
  cd cache_dir
  files.raw.map{|file_row| file_row[0]}.each { |f| expect(f).to be_an_existing_file }
end


Then(/^I should see urls for the following cached thumbnails:$/) do |table|
  table.hashes.each do |row|
    isRelative = (row['relative'].to_s == "true")
    urlPrefix = isRelative ? '' : '/'
    if(row['type'] == "img")
      imagedef = "<img src=\"#{urlPrefix}images/original.jpg?simple-thumbnailer=original.jpg%7C#{URI.encode_www_form_component(row['size'])}\" class=\"image-resized-to#{row['class']}\" alt=\"#{row['alt']}\" />"
    else
      imagedef = "<source srcset=\"#{urlPrefix}images/original.jpg?simple-thumbnailer=original.jpg%7C#{URI.encode_www_form_component(row['size'])}\" media=\"(min-width: 900px)\">"
    end

    step %Q{I should see '#{imagedef}'}
  end    
end


Then(/^the following images should exist:$/) do |table|
  table.hashes.each do |row|
    cd('.')  do
      image = MiniMagick::Image.open(row["filename"])
      expect(image.dimensions).to eq row["dimensions"].split("x").map(&:to_i)
    end
  end
end

Then(/^file "([^"]+)" should contain the following data:$/) do |file, data|
  expect(file).to be_an_existing_file
  cd('.') do
    specs = YAML.load_file(file)
    expect(specs.length).to eq(data.hashes.length)
    data.hashes.each do |hash|
      expect(specs).to include(hash)
    end
  end
end

Then(/^the file "([^"]*)" should not contain '([^']*)'$/) do |file, partial_content|
  expect(file).not_to have_file_content(Regexp.new(Regexp.escape(partial_content)), true)
end

When(/^I visit all images$/) do
  p page.body
  page.body.scan(/\<img src=\"(.*?)\"[^>]*\>/) do |m|
    p m
    visit(m[0])
  end
end
