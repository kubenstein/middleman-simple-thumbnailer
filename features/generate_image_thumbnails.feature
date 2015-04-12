Feature: Generate image thumbnails
  
  Scenario: Preserve default image_tag behaviour if no resize_to param is given
    Given the Server is running at "basic-app"
    When I go to "/page-with-untouched-image.html"
    Then I should see '<img src="/images/original.jpg" />'

  Scenario: Preserve default image_tag behaviour after build if no resize_to param was given
    Given a fixture app "basic-app"
    And a successfully built app at "basic-app"
    When I cd to "build"
    Then the file "page-with-untouched-image.html" should contain '<img src="/images/original.jpg" />'

  Scenario: Generate base64 thumbnail of image with resize_to param given
    Given the Server is running at "basic-app"
    When I go to "/page-with-images-to-resize.html"
    Then I should see base64ed thumbnails of the images

  Scenario: After build server resized images
    Given a fixture app "basic-app"
    And a successfully built app at "basic-app"
    When I cd to "build"
    Then the following images should exist:
      | filename                    | dimensions |
      | images/original.10x10gt.jpg | 10x5       |
      | images/original.5x5.jpg     |  5x2       |
    And the file "page-with-images-to-resize.html" should contain '<img class="image-resized-to10x10" src="/images/original.10x10gt.jpg" />'
    And the file "page-with-images-to-resize.html" should contain '<img class="image-resized-to5x5" src="/images/original.5x5.jpg" />'