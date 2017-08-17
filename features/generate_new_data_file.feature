Feature: Generate data file

  Scenario: Check images
    Given a fixture app "basic-app-data-file-generate"
    And a successfully built app at "basic-app-data-file"
    When I cd to "build"
    Then the following images should exist:
      | filename                    | dimensions |
      | images/original.10x10gt.jpg | 10x5       |
      | images/original.5x5.jpg     |  5x2       |

  Scenario: Check generated data file content
    Given a fixture app "basic-app-data-file-generate"
    And a successfully built app at "basic-app-data-file-generate"
    When I cd to "data"
    Then a file named "simple_thumbnailer.yaml" should exist
    And file "simple_thumbnailer.yaml" should contain the following data:
      | path         | resize_to |
      | original.jpg | 5x5       |
      | original.jpg | 10x10>    |

