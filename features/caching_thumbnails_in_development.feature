Feature: Caching thumbnails in development

  Scenario: Cached thumbnails are created
    Given the Server is running at "basic-app"
    And there is no cache directory yet
    When I go to "/page-with-images-to-resize.html"
    And I visit all images
    Then the cache directory should exist with the following files
      | images/original.10x10gt.eb4e78fd2554225b2.jpg |
      | images/original.5x5.eb4e78fd2554225b2.jpg     |

  Scenario: Cached thumbnails are used, if present
    Given the Server is running at "cached-thumbnails"
    When I go to "/page-with-images-to-resize.html"
    Then I should see urls for the following cached thumbnails:
      | type  | size  | class | relative |
      | img   | 10x10 | 10x10 | false    |
      | img   | 5x5   | 5x5   | false    |

  Scenario: Manually setting the cache directory
    Given the Server is running at "custom-cache-dir"
    When I go to "/page-with-images-to-resize.html"
    And I visit all images
    Then the cache directory should exist at "tmp/xxx" with the following files
      | images/original.10x10.eb4e78fd2554225b2.jpg |
      | images/original.5x5.eb4e78fd2554225b2.jpg   |
