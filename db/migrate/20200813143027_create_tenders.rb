class CreateTenders < ActiveRecord::Migration[5.2]
  def change
    create_table :tenders do |t|
      t.string :url
      t.string :header
      t.text :body
      t.jsonb :fields, default: {}

      t.timestamps
    end
  end
end
