class MatchMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :match

# equivalent to:
=begin
  def self.winner
  where (winner:true)
  end
=end
  scope :winner, -> { where(winner: true) }

end
