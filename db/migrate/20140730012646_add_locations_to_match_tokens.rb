class AddLocationsToMatchTokens < ActiveRecord::Migration
  def change
    add_column :match_tokens, :xloc, :integer
    add_column :match_tokens, :yloc, :integer
  end
end
