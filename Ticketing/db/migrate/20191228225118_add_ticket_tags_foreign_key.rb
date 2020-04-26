class AddTicketTagsForeignKey < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :ticket_tags, :tickets
    add_foreign_key :ticket_tags, :tags
  end
end
