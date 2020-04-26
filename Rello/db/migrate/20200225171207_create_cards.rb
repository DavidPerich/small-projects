class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :title, nil: false
      t.text :description
      t.string :labels, array: true, default: [], nil: false
      t.boolean :archived
      t.datetime :due_date
      t.boolean :completed
      t.belongs_to :list

      t.timestamps
    end
  end
end
