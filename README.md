# Datafy

## Summary

Datafy is a data mapping tool, heavily inspired by ActiveRecord.  Datafy allows you to manipulate and query backend database tables,
through Ruby class objects.  Similar to ActiveRecord, these class models are interconnected through mapped associations.

## Features

*  `::all` - returns an array of all records in db table
* `::find` - finds a single record using primary key
* `#insert` - inserts new row in db table
* `#update` - updates row using id of record
* `#save` - calls either insert/update depending on if record exists
* `#belongs_to` - inputs include association name, and additional arguments, which then is turned into a method.
* `#has_many` - inputs include association name, and additional arguments, which then is turned into a method.
* `#has_one_through` - inputs include association name, source model and through model.  It uses two belongs_to associations to generate a join query using foreign_key, primary_key and table_name.  The return value is the associated object.

##Use

To use, download/clone this repository.  Afterwards, head into pry, and load sample_model.rb.  There, you can use Datafy methods on the seed data I have provided.

**1.** Clone this directory:
```bash
git clone https://github.com/szhu1026/Datafy
```

**2.** Load pry from the root folder and seed data, as shown below:
```ruby
$ pry
[1] pry(main)> load 'test_models/sample_model.rb'
=> true

Search examples:

```ruby
# Retrieve all plants where owner_id is 2.
Plant.where(owner_id: 2)

# Retrieve all plants.
Plant.all

# Find a single plant by an id.
Plant.find(1)
