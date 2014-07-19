class Team < ActiveRecord::Base
  belongs_to :league
  has_many :tokens
  has_one :team_ownership
  has_one :user, through: :team_ownership

  validates_uniqueness_of :name

  def heal_bench_tokens
    self.tokens.off_squad.each do |token|
      soldier = token.units.last.soldiers.last
      soldier.damage = 0
      soldier.save
    end
  end

  def total_stat(stat_name)
    total_stat = 0
    tokens.on_squad.each do |token|
      soldier = token.units.first.soldiers.first
      total_stat += soldier.method(stat_name).call
    end
    total_stat
  end

end
