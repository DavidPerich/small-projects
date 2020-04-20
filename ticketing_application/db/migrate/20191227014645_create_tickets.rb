class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.string :name, :status
      t.text :body
      t.integer :project_id
      t.timestamps
    end
  end
end
