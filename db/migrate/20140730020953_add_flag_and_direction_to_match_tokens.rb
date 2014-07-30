class AddFlagAndDirectionToMatchTokens < ActiveRecord::Migration
  def change
    add_column :match_tokens, :flag, :boolean
    add_column :match_tokens, :direction, :integer
  end
end
