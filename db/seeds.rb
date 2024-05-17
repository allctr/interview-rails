# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

def clear
  puts "Clearing all the tables"
  [User, Event, Attendee, Country, City, Address]
    .each { |k| k.connection.execute("TRUNCATE TABLE #{k.table_name} RESTART IDENTITY CASCADE") }
end

def pusher(klass, size = 1000)
  to_push = []
  push = Proc.new do |h, force = false|
    (to_push << h) if h.present?
    if to_push.length >= size || (force && to_push.length > 0)
      to_push.each { |h| h.merge!(created_at: Time.current, updated_at: Time.current) }
      klass.insert_all(to_push)
      to_push = []
    end
  end
end

def countries_allowed
  @countries_allowed ||= ['Pakistan', 'United Kingdom', 'France', 'Germany', 'South Africa']
end

def cities_and_countries
  puts "Populating Cities and Countries"
  inserter = pusher(Country)
  CSV.foreach("#{Rails.root}/db/worldcities.csv", headers: true).with_index(1) do |row, lineno|
    inserter.(name: row["country"], polygon_info: { iso2: row["iso2"], iso3: row["iso3"] })
  end
  inserter.(nil, true)


  countries_allowed = ['Pakistan', 'United Kingdom', 'France', 'Germany', 'South Africa']
  country_id_by_name = Country.where(name: countries_allowed).inject({}) { |s, c| s.merge!(c.name => c.id) }

  # Get all the cities of the above countries in memory
  cities = []
  CSV.foreach("#{Rails.root}/db/worldcities.csv", headers: true).with_index(1) do |row, lineno|
    next if (country_id = country_id_by_name[row["country"]]).blank?
    cities << {
      country_id: country_id, name: row["city"], polygon_info: { population: row['population'].to_i, lat: row["lat"], lng: row["lng"] },
      created_at: Time.current, updated_at: Time.current
    }
  end

  # get the top 5% of largest cities in each country
  inserter = pusher(City)
  cities.group_by { |c| c[:country_id] }.map do |country_id, inner_cities|
    total = inner_cities.length
    inner_cities.sort_by { |c| -1 * ((c || {}).dig(:polygon_info, :population) || 0) }
      .first((total * 0.05).to_i)
      .each { |c| inserter.(c) }
  end
  inserter.(nil, true)
end

def addresses(how_many: 2000, city_ids: nil)
  puts "Populating addresses.."
  city_ids ||= City.where(country_id: Country.where(name: countries_allowed).pluck(:id)).pluck(:id)
  push = pusher(Address)
  how_many.times do |i|
    push.({
      line1: Faker::Address.secondary_address, line2: Faker::Address.street_name,
      postcode: Faker::Address.postcode, city_id: city_ids.sample,
    })
  end
  push.(nil, true)
end

def get_unused_address_id(city_ids: nil)
  @unused_addresses ||= []

  gen = Proc.new do
      Address.select("addresses.id")
        .joins("LEFT OUTER JOIN users ON users.address_id = addresses.id")
        .joins("LEFT OUTER JOIN events ON events.address_id = addresses.id")
        .where(users: { id: nil }, events: { id: nil })
        .where(city_ids.present? ? {city_id: city_ids} : {})
        .limit(1000)
        .pluck(:id)
    end

  if @unused_addresses.blank?
    @unused_addresses = gen.call
  end
  # if still blank .. generate new ones
  if @unused_addresses.blank?
    addresses(city_ids: city_ids)
    @unused_addresses = gen.call
  end

  @unused_addresses.pop
end

def users(how_many: 5000)
  puts "Populating users.."
  clean = Proc.new { |str| str.gsub(/[^a-z]/i, "").downcase }
  push = pusher(User)
  how_many.times do |i|
    push.({
        first_name: (first_name = Faker::Name.first_name),
        last_name: (last_name = Faker::Name.last_name),
        email: "#{clean.(first_name)}.#{clean.(last_name)}@gmail.com",
        address_id: get_unused_address_id,
      })
  end
  push.(nil, true)
end

def events(how_many = 300)
  # Events should be in the top 3 cities of every country
  city_ids = City.select("id, country_id, (polygon_info ->> 'population')::int as population")
    .group_by(&:country_id)
    .flat_map { |_, v| v.sort_by(&:population).reverse.first(3).map(&:id) }
  push = pusher(Event)

  event_stuff = [
      "Music.band","DcComics.title", "Book.title", "Books::CultureSeries.book", "Movie.title"
    ].map { |a| a.split(".") }.map { |k, f| Proc.new { Faker.const_get(k).send(f) } }
  event = Proc.new { event_stuff.sample.call }

  how_many.times do |i|
    push.({
      name: event.call,
      address_id: get_unused_address_id(city_ids: city_ids),
      event_date: rand(Date.parse("2020-01-01")..Date.today),
    })
  end
  push.(nil, true)
end

def attendees
  puts "Populating Attendees..."
  users = []
  user_id = Proc.new do
      users = User.order("RANDOM()").limit(1000).pluck(:id) if users.blank?
      users.pop
    end

  push = pusher(Attendee)
  Event.find_each do |event|
    rand(500..2000).times { push.(user_id: user_id.call, event_id: event.id) }
  end
  push.(nil, true)
end

def populate
  clear
  cities_and_countries
  users
  events
  attendees
end

populate

