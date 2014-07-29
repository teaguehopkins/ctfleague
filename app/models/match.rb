class Match < ActiveRecord::Base
  belongs_to :league
  has_many :match_members
  has_many :users, through: :match_members
  has_many :match_tokens
  has_many :tokens, through: :match_tokens

  scope :finished, -> { where(finished: true) }
  scope :active, -> { where(finished: [false, nil]) }

  serialize :match_log, Array

  def log(event)
    #if self.match_log == nil
    #  self.match_log = []
    #end
    self.match_log << event
    self.save
  end

  def get_log
    self.match_log
  end

  def finish
    self.finished = true
    award_points
    increase_unit_stats
    MatchMailer.send_match_results_emails(self)
    self.save
  end

  #private

  def award_points
    self.match_members.each do |match_member|
      if match_member.winner
        membership = self.league.memberships.find_by_user_id(match_member.user_id)
        membership.points = membership.points + 1
        membership.save
      end
    end
  end

  def increase_unit_stats
    side_1 = self.match_tokens.where(side: 1).to_a
    side_2 = self.match_tokens.where(side: 2).to_a

    side_1.map! do |match_token|
      match_token.token.units.first.soldiers.first
    end

    side_2.map! do |match_token|
      match_token.token.units.first.soldiers.first
    end

    side_1 = side_1.sort_by do |soldier|
      soldier.leadership
    end

    side_2 = side_2.sort_by do |soldier|
      soldier.leadership
    end

    develop_soldiers(side_1)
    develop_soldiers(side_2)
  end

  def develop_soldiers(side)
    side.each do |soldier|
      bonus = 200 * ((side.last.leadership + 5000)/10000.00)
      soldier.aim = soldier.aim + bonus
      soldier.speed = soldier.speed + bonus
      soldier.stealth = soldier.stealth + bonus
      soldier.sight = soldier.sight + bonus
      soldier.hardiness = soldier.hardiness + bonus
      soldier.leadership = soldier.leadership + bonus
      #XP +1 at the end of a match (future: where they weren't incapacitated)
      soldier.xp = soldier.xp + 1
      #rank +1 at certain XP thresholds
      promote_soldier(soldier)
      soldier.save
    end
  end

  def promote_soldier(soldier)
    @xp_base = [0,0,1,2,2,4,4,8,8,8,8,8,8]
    @league_size_modifier = 100*(self.league.teams.length-1)/5
    @xp_adjusted = @xp_base.collect {|x| x*@league_size_modifier}
    @cumulative_xp = cumulative_sum(@xp_adjusted)
    @cumulative_xp.each_with_index do |threshold, index|
      if soldier.xp * 100 >= threshold
        soldier.rank = index
      end
    end
    soldier.save
  end

  def cumulative_sum(array)
    @new_array = Array.new(array.length)
    @total = 0
    for x in 0..array.length-1
      @new_array[x] = array[x] + @total
      @total = @total + array[x]
    end
    @new_array
  end

end
