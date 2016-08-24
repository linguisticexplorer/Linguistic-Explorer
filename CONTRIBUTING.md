# Contributing Guidelines

Welcome to the Terraling Project! We are open and welcome to all external contributions and changes. To begin contributing, you must first understand the branching pattern we adhere to.

# Getting Started

To start contributing, you must have the following already:

* Git
* Github Account
* Fork of the Repository

# Branching Pattern

There are only three branches we must be concerned about for the most part. They are __master__, __patch__, and __sprint__. Each branch corresponds to different parts of the development process. We try to maintain an always deployable __master__, with __patch__ branches in case we need to make hotfixes, and a __sprint__ branch for development purposes.

## Master

The master branch always remains deployable. Merging changes to the master branch will have to go through strict review. Usually, the merges come from the sprint branch, but often we will have to make patch changes in the patch branch and merge from there. This branch is rarely ever touched directly.

## Patch

The Patch branch is responsible for having all patch level changes, such as gem updates and security fixes. These changes are then merged directly to master, reviewed, and deployed from there.

## Sprint

The sprint branch is home of all developmental changes. This branch is the most dynamic, and will experience a large amount of changes as we work our way through chores and user stories.

# Contributing

To contribute, you must first fork the repository. Once you've done that, select the branch you will be making changes on (usually sprint). If the change you are making is not listed in our issues page or our project management page, please create one before starting any changes.

## Committing

Your commits should be small and informative. Try not to have commits with large changes across multiple files, but smaller changes with only relevant files. The commit message should be a rationale on the change.

## Tests

All your changes should go under rigorous testing. When you make a change, make sure that the change is tested, or if it was previously tested, make sure that it passes.

## Pull Request (Submitting Changes)

After you've completed your commits, and you have a passing tests, feel free to make a pull request. The pull request message should indicate what changes have taken place and what it is trying to solve and/or fix. The pull request will be subject to review before merging. Once merged, you are free to make more pull requests!
