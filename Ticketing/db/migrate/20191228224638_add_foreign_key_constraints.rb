class AddForeignKeyConstraints < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :tickets, :projects
    add_foreign_key :tags, :tickets
  end
end
