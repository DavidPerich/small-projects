# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Board.destroy_all
List.destroy_all
Card.destroy_all

board1 = Board.create title: "First board"

list1 = List.create title: "first list", board: board1
list2 = List.create title: "second list", board: board1

card1 = Card.create title: "card 1 list 1", list: list1
card2 = Card.create title: "card 2 list 1", list: list1

card1 = Card.create title: "card 1 list 2", list: list2
card2 = Card.create title: "card 2 list 2", list: list2
card3 = Card.create title: "card 3 list 2", list: list2