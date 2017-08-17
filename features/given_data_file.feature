Feature: Use data file

  Scenario: Check images from data file
    Given a fixture app "basic-app-data-file"
    And a successfully built app at "basic-app-data-file"
    When I cd to "build"
    Then the following images should exist:
      | filename                    | dimensions |
      | images/original.10x10.jpg   | 10x5       |
      | images/original.10x10gt.jpg | 10x5       |
      | images/original.5x5.jpg     |  5x2       |

  Scenario: Check data file content
    Given a fixture app "basic-app-data-file"
    And a successfully built app at "basic-app-data-file"
    When I cd to "data"
    Then a file named "simple_thumbnailer.yml" should exist
    And file "simple_thumbnailer.yml" should contain the following data:
      | path         | resize_to |
      | original.jpg | 10x10     |
      | *.jpg        | 5x5       |
      | original.jpg | 10x10>    |

  Scenario: Check sitemap file
    Given a successfully built app at "basic-app-data-file"
    When I cd to "build"
    Then a file named "sitemap.html" should exist
    And the file "sitemap.html" should contain '<li><a href="/images/original.10x10.jpg">/images/original.10x10.jpg</a></li>'
    And the file "sitemap.html" should contain '<li><a href="/images/original.5x5.jpg">/images/original.5x5.jpg</a></li>'
    And the file "sitemap.html" should not contain '<li><a href="/images/original.10x10gt.jpg">/images/original.10x10gt.jpg</a></li>'
