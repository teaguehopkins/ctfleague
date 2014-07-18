class AddMatchLogToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :match_log, :text
  end
end
