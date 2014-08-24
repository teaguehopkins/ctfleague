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
    @team_1 = self.users.first.teams.find_by_league_id(self.league.id)
    @team_2 = self.users.last.teams.find_by_league_id(self.league.id)

    initialize_match_tokens(@team_1, 1)
    initialize_match_tokens(@team_2, 2)
    activate_all_match_tokens

    @flagwinner = nil
    until @flagwinner != nil do
      output_turn_status_to_log
      sim_one_turn
    end
      @flagwinner.winner = true
      @flagwinner.save
  end

  private

  def activate_all_match_tokens
    self.match_tokens.each do |match_token|
      match_token.token.units.first.soldiers.first.update active: true
    end
  end

  def initialize_match_tokens(team, side)
    if side == 1
      xloc = 0
      direction = 1
    else #side = 2
      xloc = 1000
      direction = -1
    end
    team.tokens.on_squad.each do |token|
      self.match_tokens.create(:token => token, :side => side, :xloc => xloc, :direction => direction, :flag => false, :spotted => false)
      token.units.first.soldiers.first.reset_match_stats
    end
  end

  def output_turn_status_to_log
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
  end

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
            check_if_token_captured_flag(match_token)
          end
        else
          match_token.run
          match_token.flag_grab
          check_if_token_captured_flag(match_token)
        end
      end
    end
  end

  def check_if_token_captured_flag(match_token)
    #TODO Fix ties. Currently does not handle ties - ties go to side 1
    if match_token.flag && match_token.xloc == 0 && match_token.side == 1
      self.log(match_token.soldier.last_name + " has captured the flag!")
      match_token.soldier.capture
      set_winning_team(@team_1)
    elsif match_token.flag && match_token.xloc == 1000 && match_token.side == 2
      self.log(match_token.soldier.last_name + " has captured the flag!")
      match_token.soldier.capture
      set_winning_team(@team_2)
    end
  end

  def set_winning_team(team)
    @flagwinner = self.match_members.where(user_id: team.user.id).first
    self.log(team.name + " wins!")
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
    #get soldiers as array
    side.map! do |match_token|
      match_token.token.units.first.soldiers.first
    end

    #sets the bonus before increasing stats, otherwise some soldies will get a bonus based on leadership increased this round.
    bonus = leadership_bonus(side)

    side.each do |soldier|
      increase = 200 * bonus
      soldier.aim = soldier.aim + increase
      soldier.speed = soldier.speed + increase
      soldier.stealth = soldier.stealth + increase
      soldier.sight = soldier.sight + increase
      soldier.hardiness = soldier.hardiness + increase
      soldier.leadership = soldier.leadership + increase
      #XP +1 at the end of a match (future: where they weren't incapacitated)
      soldier.xp = soldier.xp + 1
      #rank +1 at certain XP thresholds
      promote_soldier(soldier)
      soldier.save
    end
  end

  def leadership_bonus(side)
    #sort soldiers by leadership
    side = side.sort_by do |soldier|
      soldier.leadership
    end
    #return highest leadership
    bonus = (side.last.leadership + 5000)/10000.00
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
