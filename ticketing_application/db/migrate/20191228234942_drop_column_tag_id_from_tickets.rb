class DropColumnTagIdFromTickets < ActiveRecord::Migration[6.0]
  def change
    remove_column :tags, :ticket_id
  end
end
