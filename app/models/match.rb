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
    @team_1.heal_bench_tokens
    @team_2.heal_bench_tokens
    award_points
    increase_unit_stats
    MatchMailer.send_match_results_emails(self)
    self.save
  end

  def simulate
    @league = self.league
    @team_1 = self.users.first.teams.find_by_league_id(@league.id)
    @team_2 = self.users.last.teams.find_by_league_id(@league.id)
    @team_1.tokens.on_squad.each do |token|
      self.match_tokens.create(:token => token, :side => 1, :xloc => 0, :direction => 1, :flag => false, :spotted => false)
    end

    @team_2.tokens.on_squad.each do |token|
      self.match_tokens.create(:token => token, :side => 2, :xloc => 1000, :direction => -1, :flag => false, :spotted => false)
    end

      self.match_tokens.each do |match_token|
        match_token.token.units.first.soldiers.first.update active: true
      end

    @flagwinner = nil
    until @flagwinner != nil do
      self.log("======================================= New Round =======================================")
      self.match_tokens.sort { |a, b| b.init <=> a.init }.each do |match_token| #order tokens by speed
        vis = ""
        vis = "_____Vis" if match_token.spotted
        vis = vis + "_____Flag" if match_token.flag
        if match_token.side == 1 && match_token.soldier.active
          self.log(match_token.soldier.last_name + " at " + match_token.xloc.to_s + " " + vis)
        end
        if match_token.side == 2 && match_token.soldier.active
          self.log("_____________________________________________" + match_token.soldier.last_name + " at " + match_token.xloc.to_s + " " + vis)
        end
      end
    self.log("--------------------------------------- Actions ---------------------------------------")
      sim_one_turn
    end
      @flagwinner.winner = true
      @flagwinner.save
  end

  private

  def sim_one_turn
    self.match_tokens.each do |match_token|
      if match_token.soldier.active
        match_token.check_sights
        if match_token.opponents_visible
          if match_token.can_hit(match_token.nearest_opponent)
            match_token.shoot(match_token.nearest_opponent)
          else
            match_token.run
            match_token.flag_grab
            flag_winner(match_token)
          end
        else
          match_token.run
          match_token.flag_grab
          flag_winner(match_token)
        end
      end
    end
  end

  def flag_winner(match_token)
    #check flag win conditions - does not handle ties - ties go to side 1
    if match_token.flag && match_token.xloc == 0 && match_token.side == 1
      self.log(match_token.soldier.last_name + " has captured the flag!")
      @flagwinner = self.match_members.where(user_id: @team_1.user.id).first
      self.log(@team_1.name + " wins!")
    elsif match_token.flag && match_token.xloc == 1000 && match_token.side == 2
      self.log(match_token.soldier.last_name + " has captured the flag!")
      self.log(@team_2.name + " wins!")
      @flagwinner = self.match_members.where(user_id: @team_2.user.id).first
    end
  end

  def award_points
    winner = self.match_members.where(winner: true).first
    membership = self.league.memberships.find_by_user_id(winner.user_id)
    membership.points = membership.points + 1
    membership.save
  end

  def increase_unit_stats
    side_1 = self.match_tokens.where(side: 1).to_a
    side_2 = self.match_tokens.where(side: 2).to_a

    develop_soldiers(side_1)
    develop_soldiers(side_2)
  end

  def develop_soldiers(side) #TODO Make this affected by injuries
    side.map! do |match_token|
      match_token.token.units.first.soldiers.first
    end

    side = side.sort_by do |soldier|
      soldier.leadership
    end

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
