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

 `$ cp yamls/database.yml.example config/database.yml`

  Edit your MySQL account data for development and test environment:

 `$ vim config/database.yml`

  Create tables and seed them

  `$ rake db:setup`

* Run it!

  `$ rails server`

### YAML example files

YAML files are now stored in the `yamls` folder: have a look there to configure:

* your MySQL database (see above)
* the import task for CSVs files
* the SSWL import task (for SSWL administrators)

#### Seed Data

Download seed data from here:

  `$ git clone git://github.com/dej611/terraling_seed.git`

Copy seed data to the doc/data in Terraling:

  `$ cp -r <path_to_Terraling_seed>/terraling_seed/data <path_to_terraling>/db/seed`
  
## Contributing

Terraling has currently 3 main branches:

* master - this branch contains the latest major version
* patch - this branch contains the latest minor version (usually the deployed one)
* sprint - this branch contains the development code for the newer version

### Master Status

[![Build Status](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer.png?branch=master)](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer)
[![Dependency Status](https://gemnasium.com/linguisticexplorer/Linguistic-Explorer.png)](https://gemnasium.com/linguisticexplorer/Linguistic-Explorer)
[![Code Climate](https://codeclimate.com/github/linguisticexplorer/Linguistic-Explorer.png)](https://codeclimate.com/github/linguisticexplorer/Linguistic-Explorer)

### Patch Status

[![Build Status](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer.png?branch=patch)](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer)

### Sprint Status

[![Build Status](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer.png?branch=sprint)](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer)

## Test it

To test yourself the app write in the console

  `$ rake`
  
It should run both rspec and cucumber tests.
  
## Contribute

We are looking for some help in this project. Want to help us?

[How To Contribute](https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/How-To-Contribute)
  
## License
This project is under the MIT License.

Please have a look to the [LICENSE file](https://github.com/linguisticexplorer/Linguistic-Explorer/blob/master/LICENSE).
