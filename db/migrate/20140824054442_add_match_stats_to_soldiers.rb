class AddMatchStatsToSoldiers < ActiveRecord::Migration
  def change
    add_column :soldiers, :spots, :integer
    add_column :soldiers, :hits, :integer
    add_column :soldiers, :kills, :integer
    add_column :soldiers, :sneaks, :integer
    add_column :soldiers, :grabs, :integer
    add_column :soldiers, :captures, :integer
  end
end
