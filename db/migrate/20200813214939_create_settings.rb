class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.references :user
      t.jsonb :filters
      t.integer :last_sended_tender_id
      t.string :keywords

      t.timestamps
    end
  end
end
