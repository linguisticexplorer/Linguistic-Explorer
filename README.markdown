Linguistic Explorer: Terraling
====

![http://linguisticexplorer.org](http://linguisticexplorer.org/images/lexplorer_logo4.png)

http://www.terraling.com

Terraling is a Ruby on Rails web application to let you store and browse your linguistic data and now it has new features like the following:

* [Regular Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Regular-search);

* [Cross Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Cross-search);

* [Compare Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Compare-search);

* [Universal Implication Both Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Both-Implication);

* [Universal Implication Antecedent Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Antecedent-Implication);

* [Universal Implication Consequent Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Consequent-Implication);

* [Universal Implication Double Both Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Double-Both-Implication);

* [Geomapping] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Geomapping-feature) of all the searches above and filter results by category/row;

* [Similarity Tree Search] (https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/Similarity-tree);

## Install

#### Requirements
* Ruby 1.9.x
* MySQL 5.5.x
* [R server](http://cran.r-project.org/doc/FAQ/R-FAQ.html#How-can-R-be-installed_003f)

#### How to

* Download it!

  `$ git clone git://github.com/linguisticexplorer/Linguistic-Explorer.git`

* Bundle it!

  `$ cd Linguistic-Explorer`

  `$ bundle install`

* Configure it!

 `$ cp config/database.yml.example config/database.yml`

  Edit your MySQL account data for development and test environment:

 `$ vim config/database.yml`

  Create tables and seed them

  `$ rake db:setup`

* Run it!

  `$ rails s`

#### Seed Data

Download seed data from here:

  `$ git clone git://github.com/dej611/terraling_seed.git`

Copy seed data to the doc/data in Terraling:

  `$ cp -r <path_to_Terraling_seed>/terraling_seed/data <path_to_terraling>/db/seed`
  
## Test it

[![Build Status](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer.png?branch=devel)](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer)

To test yourself the app write in the console

  `$rake`
  
It should run both rspec and cucumber tests.
  
## Contribute

We are looking for some help in this project. Want to help us?

Fork this repo, pick one issue from the list and pull the fix back!
  
## License
This project is under the MIT License.

Please have a look to the [LICENSE file](https://github.com/linguisticexplorer/Linguistic-Explorer/blob/master/LICENSE).
