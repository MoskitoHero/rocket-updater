class AddDoneToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :done, :boolean, default: false
  end
end
