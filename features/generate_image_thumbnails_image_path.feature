Feature: Generate image thumbnails with image path

  Scenario: Preserve default image_path behaviour if no resize_to param is given
    Given the Server is running at "basic-app-image-path"
    When I go to "/page-with-untouched-image.html"
    Then I should see '<img src="/images/original.jpg" alt="Original" />'
    And I should see '<source srcset="/images/original.jpg" media="(min-width: 900px)">'

  Scenario: Preserve default image_path behaviour after build if no resize_to param was given
    Given a fixture app "basic-app-image-path"
    And a successfully built app at "basic-app-image-path"
    When I cd to "build"
    Then the file "page-with-untouched-image.html" should contain '<img src="/images/original.jpg" alt="Original" />'
    And the file "page-with-untouched-image.html" should contain '<source srcset="/images/original.jpg" media="(min-width: 900px)">'

  Scenario: Generate base64 thumbnail of image with resize_to param given
    Given the Server is running at "basic-app-image-path"
    When I go to "/page-with-images-to-resize.html"
    Then I should see base64ed thumbnails and srcset of the images

  Scenario: After build server resized images
    Given a fixture app "basic-app-image-path"
    And a successfully built app at "basic-app-image-path"
    When I cd to "build"
    Then the following images should exist:
      | filename                    | dimensions |
      | images/original.10x10gt.jpg | 10x5       |
      | images/original.5x5.jpg     |  5x2       |
      | images/original.20x20.jpg   | 20x9       |
      | images/original.15x15.jpg   | 15x7       |
    And the file "page-with-images-to-resize.html" should contain '<img src="/images/original.10x10gt.jpg" class="image-resized-to10x10" alt="Original.10x10gt" />'
    And the file "page-with-images-to-resize.html" should contain '<source srcset="/images/original.20x20.jpg" media="(min-width: 900px)">'
    And the file "page-with-images-to-resize.html" should contain '<img src="/images/original.5x5.jpg" class="image-resized-to5x5" alt="Original.5x5" />'
    And the file "page-with-images-to-resize.html" should contain '<source srcset="/images/original.15x15.jpg" media="(min-width: 900px)">'