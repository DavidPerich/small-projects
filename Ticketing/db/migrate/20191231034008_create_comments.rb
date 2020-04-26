class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.belongs_to :creator, foreign_key: {to_table: :users}, null: false
      t.belongs_to :ticket, foreign_key: true, null: false
      t.timestamps
    end
  end
end
