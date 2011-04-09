Kitchen: It's where Chefs cook
==============================

Kitchen is an alternative to the default chef-server.  It allows you to manage your infrastructure with more of a git workflow over the default workflow focused on versioning recipes.

Kitchen is targeting Chef 0.10, as it introduces several API changes as well as the concept of "environments".

Goals
-----

Kitchen was born out of a realization that the traditional chef-server didn't fit the type of workflow I wanted.

* I wanted to version my infrastructure instead of individual cookbooks.
* Changes often cross several cookbooks and are interdependent.
* We maintain several different environments, some of which are ahead of production in their infrastructure for testing/development.
* We'll be developing major infrastructure changes in a branch of our chef repo while still supporting the existing infrastructure in another.

We aimed to solve these problems by:

* Having kitchen work directly off our repository of cookbooks/roles.
* Rather than using knife to upload changes, we just commit and push that branch
* We switch environments, roles, or individual nodes to use different branches.

**Kitchen is very very much ALPHA. At best, it is a semi-working prototype.**

It is under active development, but still very rough under the edges. Right now is is simply a prototype. A lot of the code is still pretty ugly in parts, as it was focused on "what do I gotta do to make this sort of work".  Refinement and actual specs are coming soon.

As Chef 0.10 is still just a beta, it may also be changing as well.

Contributing
------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important.
* Commit, do not mess with Rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2011 Ken Robertson. See LICENSE for details.