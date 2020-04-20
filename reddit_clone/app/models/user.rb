class User < ApplicationRecord
  has_many :posts
  has_many :comments
  has_many :votes

  has_secure_password validations: false
  validates :name, presence: true, uniqueness: true
  validates :password, presence: true, length: {minimum: 5}, on: :create
end
