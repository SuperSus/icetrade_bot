class AddActiveToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :active, :boolean, default: false
  end
end
