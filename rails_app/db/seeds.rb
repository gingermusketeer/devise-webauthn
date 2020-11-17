# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
test1 = User.find_or_initialize_by(email: "test1@localhost")
test1.update!(password: "password")
test2 = User.find_or_initialize_by(email: "test2@localhost")
test2.update!(password: "password")
