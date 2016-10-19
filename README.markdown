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
* Ruby 1.9.3 - if you are stuck with 1.9.2 use version 1.3.3
* MySQL 5.5.x

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
The seed data is included within the Terraling project, so you can quickly start a new example group by running the following:

  `$ rake db:seed`

## Branches Status

### Master

[![Build Status](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer.png?branch=master)](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer)
[![Dependency Status](https://gemnasium.com/linguisticexplorer/Linguistic-Explorer.png)](https://gemnasium.com/linguisticexplorer/Linguistic-Explorer)
[![Code Climate](https://codeclimate.com/github/linguisticexplorer/Linguistic-Explorer.png)](https://codeclimate.com/github/linguisticexplorer/Linguistic-Explorer)

### Development

[![Build Status](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer.png?branch=devel)](https://travis-ci.org/linguisticexplorer/Linguistic-Explorer)

## Test it

To test yourself the app write in the console

  `$ rake`
  
It should run both rspec and cucumber tests.

**Note**
If you are having issues when running the tests with the following line:
```
> [WARN] table 'Role' doesn't exist. Did you run the migration? Ignoring rolify config.
```
To fix this issue run the following:
```
$ rake db:test:prepare db:test:load
```
Then try to run the tests again.
  
## Contribute

We are looking for some help in this project. Want to help us?

[How To Contribute](https://github.com/linguisticexplorer/Linguistic-Explorer/wiki/How-To-Contribute)
  
## License
This project is under the MIT License.

Please have a look to the [LICENSE file](https://github.com/linguisticexplorer/Linguistic-Explorer/blob/master/LICENSE).
