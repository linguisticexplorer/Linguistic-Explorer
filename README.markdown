Linguistic Explorer: Terraling
====

http://linguisticexplorer.org

http://www.terraling.com

Terraling is a Ruby on Rails web application to let you store and browse your linguistic data and now it has new features like the following:

* Cross Search;

* Compare Search;

* Universal Implication Both Search;

* Universal Implication Antecedent Search;

* Universal Implication Consequent Search;

* Universal Implication Double Both Search;

* Similarity Tree Search;

* Geomapping of all the searches above! (and now with filter ;) )

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
  
## Contribute

We are looking for some help in this project. Want to help us?

Fork this repo, pick one issue from the list and pull the fix back!
  
## License
This project is under the MIT License.

Please have a look to the [LICENSE file](https://github.com/linguisticexplorer/Linguistic-Explorer/blob/master/LICENSE).

### Markers license
Icons used for the Geomapping feature are under the [Creative Commons Attribution-Share Alike 3.0 Unported license (CC BY SA 3.0)] (http://creativecommons.org/licenses/by-sa/3.0/)
Thanks to the [Maps Icons Collection] (http://mapicons.nicolasmollet.com/) project for the icons.
![Maps Icons Collection Logo](http://mapicons.nicolasmollet.com/wp-content/uploads/2011/03/miclogo-88x31.gif)
