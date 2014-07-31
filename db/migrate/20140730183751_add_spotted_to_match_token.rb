class AddSpottedToMatchToken < ActiveRecord::Migration
  def change
    add_column :match_tokens, :spotted, :boolean
  end
end
