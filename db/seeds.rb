# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
filters = [
  # {name: 'Count of room', key: 'roomCount', filter_type: :unclude},
  {name: 'Max price', key: 'priceMax', filter_type: :less_then},
  {name: 'Min price', key: 'priceMin', filter_type: :more_then},
  # {name: 'Currency', key: 'currency', filter_type: :bool},
  # {name: 'With photo', key: 'hasPhotos', filter_type: :bool},
]
Filter.create(filters)
