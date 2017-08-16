# acts_as_network

This gem is intended to simplify the definition 
and storage of reciprocal relationships between entities using
`ActiveRecord`, exposing a "network" of two-way connections between
records. It does this in DRY way using only **a single record**
in a `has_and_belongs_to_many` join table or `has_many :through` 
join model. Thus, there is no redundancy and you need only one instance of 
an association or join model to represent both directions of the relationship.

This is especially useful for social networks where 
a *friend* relationship in one direction implies the reverse
relationship (when Jack is a friend of Jane, Jane should also
be a friend of Jack). 

## History

[Zetetic LLC](http://www.zetetic.net) extracted `acts_as_network` from
[PingMe](http://www.gopingme.com) where it drives the social 
networking features of the site.

[ExamTime](http://www.examtime.com) forked the project in February 2012
to repackage it from a Rails 2 plugin to a Rails 3 gem. Minimal code
changes have been made. Significant changes were pulled in from
[Erik Hollensbe's
fork](https://github.com/erikh/acts_as_network/commits/rails3/lib/zetetic/acts)

## Installation

Add this line to your application's `Gemfile`:

    gem 'acts_as_network'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_network

## Contributing

This fork is maintained on GitHub:
  git@github.com:ExamTime/acts_as_network.git

The original project is here:
  http://github.com/sjlombardo/acts_as_network/tree/master

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Usage

The usual way of representing network relationships in a database is 
to use an intermediate, often self-referential, join table (HABTM). 
For example one might define a simple `Person` type

```ruby
  create_table :people, :force => true do |t|
    t.column :name, :string
  end
```

and then a join table to store the friendship relation

```ruby
  create_table :friends, {:id => false} do |t|
    t.column :person_id, :integer, :null => false
    t.column :person_id_friend, :integer, :null => false      # target of the relationship
  end
```

Unfortunately this model requires *two* rows in the intermediate table to
make a relationship bi-directional

```ruby
  jane = Person.create(:name => 'Jane')
  jack = Person.create(:name => 'Jack')

  jane.friends << jack          # Jack is Jane's friend
  jane.friends.include?(jack)   # => true
```

Clearly Jack is Jane's friend, yet Jane is *not* Jack's friend

```ruby
  jack.friends.include?(jane)   # => false
```

unless you need to explicitly define the reverse relation

```ruby
  jack.friends << jane
```

Of course, this isn't horrible, and can in fact be implemented
in a fairly DRY way using association callbacks. However, things get
more complicated when you consider disassociation (what to do when Jane 
doesn't want to be friends with Jack any more), or the very common
case where you want to express the relationship through a more complicated
join model via `has_many :through`

```ruby
  create_table :invites do |t|
    t.column :person_id, :integer, :null => false           # source of the relationship
    t.column :person_id_friend, :integer, :null => false    # target of the relationship
    t.column :code, :string                                 # random invitation code
    t.column :message, :text                                # invitation message
    t.column :is_accepted, :boolean
    t.column :accepted_at, :timestamp                       # when did they accept?
  end
```

In this case creating a reverse relationship is painful, and depending on 
validations might require the duplication of multiple values, making the
data model decidedly un-DRY.

### Using acts_as_network

Acts As Network DRYs things up by representing only a single record
in a `has_and_belongs_to_many` join table or `has_many :through` 
join model. Thus, you only need one instance of an association or join model to
represent both directions of the relationship.

### With HABTM

For a HABTM style relationship, it's as simple as

```ruby
  class Person < ActiveRecord::Base
    acts_as_network :friends, :join_table => :friends
  end
```

In this case `acts_as_network` will expose three new properies
on the Person model

```ruby
  me.friends_out    # friends where I have originated the friendship
                    # (people I consider friends)

  me.friends_in     # friends where they originated the friendship
                    # (people who consider me a friend)

  me.friends        # the union of the two sets, that is all people who I consider
                    # friends and all those who consider me a friend
```

Thus

```ruby
  jane = Person.create(:name => 'Jane')
  jack = Person.create(:name => 'Jack')
  
  jane.friends_out << jack                  # Jane adds Jack as a friend
  jane.friends.include?(jack)    =>  true   # Jack is Janes friend
  jack.friends.include?(jane)    =>  true   # Jane is also Jack's friend!
```

### With a join model

This may seem more natural when considering a join style with a proper Invite model. In this case
one person will "invite" another person to be friends.

```ruby
  class Invite < ActiveRecord::Base
    belongs_to :person
    belongs_to :person_target, :class_name => 'Person', :foreign_key => 'person_id_target'        # the target of the friend relationship 
    validates_presence_of :person, :person_target
  end

  class Person < ActiveRecord::Base
    acts_as_network :friends, :through => :invites, [:conditions => "is_accepted = ?", true]
  end
```

In this case `acts_as_network` implicitly defines five new properties on
the `Person` model:

```ruby
  person.invites_out      # has_many invites originating from me to others
  person.invites_in       # has_many invites orginiating from others to me
  person.friends_out      # has_many friends :through outbound accepted invites from me to others
  person.friends_in       # has_many friends :through inbound accepted invites from others to me
  person.friends          # the union of the two friend sets - all people who I have
                          # invited and all the people who have invited me
```

Thus

```ruby
  jane = Person.create(:name => 'Jane')
  jack = Person.create(:name => 'Jack')

  # Jane invites Jack to be friends
  invite = Invite.create(:person => jane, :person_target => jack, :message => "let's be friends!")

  jane.friends.include?(jack)    =>  false   # Jack is not yet Jane's friend
  jack.friends.include?(jane)    =>  false   # Jane is not yet Jack's friend either

  invite.is_accepted = true  # Now Jack accepts the invite
  invite.save and jane.reload and jack.reload

  jane.friends.include?(jack)    =>  true   # Jack is Jane's friend now
  jack.friends.include?(jane)    =>  true   # Jane is also Jack's friend
```

For more details and specific options see `ActsAsNetwork::Network::ClassMethods`

The applications of this plugin to social network situations are fairly obvious,
but it should also be usable in the general case to represent inherant 
bi-directional relationships between entities.

#### Migrations

This Gem does not attempt to help you write your migrations. For the
join example above, the changes to the model and the corresponding
migrations would be:

```ruby
class Person < ActiveRecord::Base
  ...
  acts_as_network :friends,
    :through => :invites,
    :conditions => [ "is_accepted = ?", true ],
    :association_foreign_key => "person_target_id"
```

```ruby
class CreateInvite < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :person_id
      t.integer :person_target_id
      t.text    :message
      t.boolean :is_accepted
      t.timestamps
    end
  end
end

class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :person_id
      t.integer :person_id_friend
      t.timestamps
      end
  end
end
```

## Tests

The plugin's unit tests are located in `test` directory under 
`vendor/plugins/acts_as_network`. Run:

```
  [%] cd vendor/plugins/acts_as_network
  [%] ruby test/network_test.rb
```

This will create a temporary `sqlite3` database, a number of tables,
fixture data, and run the tests. You can delete the sqlite database
when you are done.

```
  [%] rm acts_as_network.test.db
```

The test suite requires `sqlite3`.
