class AddCreatedByToPosts < ActiveRecord::Migration[7.0]
  def change
    add_reference :posts, :created_by, foreign_key: { to_table: :users }
  end
end
