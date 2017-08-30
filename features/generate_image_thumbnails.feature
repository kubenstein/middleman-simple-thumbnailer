Feature: Generate image thumbnails

  Scenario: Preserve default image_tag behaviour if no resize_to param is given
    Given the Server is running at "basic-app"
    When I go to "/page-with-untouched-image.html"
    Then I should see '<img src="/images/original.jpg" alt="Original" />'

  Scenario: Preserve default image_tag behaviour after build if no resize_to param was given
    Given a fixture app "basic-app"
    And a successfully built app at "basic-app"
    When I cd to "build"
    Then the file "page-with-untouched-image.html" should contain '<img src="/images/original.jpg" alt="Original" />'

  Scenario: Generate base64 thumbnail of image with resize_to param given
    Given the Server is running at "basic-app"
    When I go to "/page-with-images-to-resize.html"
    Then I should see urls for the following cached thumbnails:
      | type | size   | class | relative | alt              |
      | img  | 10x10> | 10x10 | false    | Original.10x10gt |
      | img  | 5x5    | 5x5   | false    | Original.5x5     |


  Scenario: After build server resized images
    Given a fixture app "basic-app"
    And a successfully built app at "basic-app"
    When I cd to "build"
    Then the following images should exist:
      | filename                    | dimensions |
      | images/original.10x10gt.jpg | 10x5       |
      | images/original.5x5.jpg     |  5x2       |
    And the file "page-with-images-to-resize.html" should contain '<img src="/images/original.10x10gt.jpg" class="image-resized-to10x10" alt="Original.10x10gt" />'
    And the file "page-with-images-to-resize.html" should contain '<img src="/images/original.5x5.jpg" class="image-resized-to5x5" alt="Original.5x5" />'

  Scenario: Not using resize_to should nt fail the build
    Given a fixture app "basic-app-no-resize"
    And a successfully built app at "basic-app-no-resize"
    When I cd to "build"
    Then the file "page-with-untouched-image.html" should contain '<img src="/images/original.jpg" alt="Original" />'
