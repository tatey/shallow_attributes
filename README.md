# ShallowAttributes


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shallow_attributes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shallow_attributes

## Examples

### Using ShallowAttributes with Classes
You can create classes extended with Virtus and define attributes:

```ruby
class User
  include ShallowAttributes

  attribute :name, String
  attribute :age, Integer
  attribute :birthday, DateTime
end

user = User.new(name: 'Anton', age: 31)
user.name # => "Anton"

user.age = '31' # => 31
user.age.class # => Fixnum

user.birthday = 'November 18th, 1983' # => #<DateTime: 1983-11-18T00:00:00+00:00 (4891313/2,0/1,2299161)>

user.attributes # => { name: "Anton", age: 31, birthday: nil }

# mass-assignment
user.attributes = { name: 'Jane', age: 21 }
user.name # => "Jane"
user.age  # => 21
```

### Default Values

``` ruby
class Page
  include ShallowAttributes

  attribute :title, String

  # default from a singleton value (integer in this case)
  attribute :views, Integer, default: 0

  # default from a singleton value (boolean in this case)
  attribute :published, 'Boolean', default: false

  # default from a callable object (proc in this case)
  attribute :slug, String, default: lambda { |page, attribute| page.title.downcase.gsub(' ', '-') }

  # default from a method name as symbol
  attribute :editor_title, String,  default: :default_editor_title

  def default_editor_title
    published ? title : "UNPUBLISHED: #{title}"
  end
end

page = Page.new(title: 'Virtus README')
page.slug         # => 'virtus-readme'
page.views        # => 0
page.published    # => false
page.editor_title # => "UNPUBLISHED: Virtus README"

page.views = 10
page.views                    # => 10
page.reset_attribute(:views)  # => 0
page.views                    # => 0
```

## Embedded Value

``` ruby
class City
  include ShallowAttributes

  attribute :name, String
  attribute :size, Integer, default: 9000
end

class Address
  include ShallowAttributes

  attribute :street,  String
  attribute :zipcode, String, default: '111111'
  attribute :city,    City
end

class User
  include ShallowAttributes

  attribute :name,    String
  attribute :address, Address
end

user = User.new(address: {
  street: 'Street 1/2',
  zipcode: '12345',
  city: {
    name: 'NYC'
  }
})

user.address.street # => "Street 1/2"
user.address.city.name # => "NYC"
```

### Custom Coercions

``` ruby
require 'json'

class Json
  def coerce(value)
    value.is_a?(::Hash) ? value : JSON.parse(value)
  end
end

class User
  include ShallowAttributes

  attribute :info, Json, default: {}
end

user = User.new
user.info = '{"email":"john@domain.com"}' # => {"email"=>"john@domain.com"}
user.info.class # => Hash

# With a custom attribute encapsulating coercion-specific configuration
class NoisyString
  def coerce(value)
    value.to_s.upcase
  end
end

class User
  include ShallowAttributes

  attribute :scream, NoisyString
end

user = User.new(scream: 'hello world!')
user.scream # => "HELLO WORLD!"
```

### Collection Member Coercions

``` ruby
# Support "primitive" classes
class Book
  include ShallowAttributes

  attribute :page_numbers, Array, of: Integer
end

book = Book.new(:page_numbers => %w[1 2 3])
book.page_numbers # => [1, 2, 3]

# Support EmbeddedValues, too!
class Address
  include ShallowAttributes

  attribute :address,     String
  attribute :locality,    String
  attribute :region,      String
  attribute :postal_code, String
end

class PhoneNumber
  include ShallowAttributes

  attribute :number, String
end

class User
  include ShallowAttributes

  attribute :phone_numbers, Array, of: PhoneNumber
  attribute :addresses,     Array, of: Address
end

user = User.new(
  :phone_numbers => [
    { :number => '212-555-1212' },
    { :number => '919-444-3265' } ],
  :addresses => [
    { :address => '1234 Any St.', :locality => 'Anytown', :region => "DC", :postal_code => "21234" } ])

user.phone_numbers # => [#<PhoneNumber:0x007fdb2d3bef88 @number="212-555-1212">, #<PhoneNumber:0x007fdb2d3beb00 @number="919-444-3265">]
user.addresses # => [#<Address:0x007fdb2d3be448 @address="1234 Any St.", @locality="Anytown", @region="DC", @postal_code="21234">]

user.attributes # => {
                # =>   :phone_numbers => [
                # =>     { :number => '212-555-1212' },
                # =>     { :number => '919-444-3265' } ],
                # =>   :addresses => [
                # =>     { :address => '1234 Any St.', :locality => 'Anytown', :region => "DC", :postal_code => "21234" } ]
                # => }
```

### Overriding setters

``` ruby
class User
  include Virtus.model

  attribute :name, String

  alias_method :_name=, :name=
  def name=(new_name)
    custom_name = nil
    if new_name == "Godzilla"
      custom_name = "Can't tell"
    end

    self._name = custom_name || new_name
  end
end

user = User.new(name: "Frank")
user.name # => 'Frank'

user = User.new(name: "Godzilla")
user.name # => 'Can't tell'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davydovanton/shallow_attributes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

