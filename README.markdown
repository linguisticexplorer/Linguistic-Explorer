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

#### Install

Requirements
============
* Ruby 1.9.x
* MySQL 5.5.x
* [R server](http://cran.r-project.org/doc/FAQ/R-FAQ.html#How-can-R-be-installed_003f)

How to
======

* Download it!

  `$ git clone git@github.com:linguisticexplorer/Linguistic-Explorer.git`

* Bundle it!

  `$ cd Linguistic-Explorer
   $ bundle install`

* Configure it!

 `$ cp db/database.yml.example db/database.yml`

  Edit your MySQL account data for development and test environment:

 `$ vim db/database.yml`

  Create tables and seed them

  `$ rake db:setup`

* Run it!

  `$ rails s`

#### Seed Data

Download seed data from here:

  `$ git clone git@github.com:dej611/terraling_seed.git`

Copy seed data to the doc/data in Terraling:

  `$ cp -r <path_to_Terraling_seed>/terraling_seed/data <path_to_terraling>/doc/data`