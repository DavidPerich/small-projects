class Ticket < ActiveRecord::Base
  STATUS_OPTIONS = %w(new blocked in_progress fixed)

  belongs_to :project
  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :ticket_tags, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :tags, through: :ticket_tags

  validates :name, presence: true, length: {minimum: 3}
  validates :status, presence: true
  validates :body, presence: true
  validates_inclusion_of :status, in: STATUS_OPTIONS, message: "%{value} is not a valid status"


  scope :open, -> { where("status != ?", "fixed") }
end
