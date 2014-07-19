class MatchesController < ApplicationController
  def ready
    @match = Match.find(params[:id])
    @league = League.find(params[:league_id])

    if check_squad_size
      match_member = @match.match_members.find_by_user_id(current_user.id)
      match_member.ready = true
      match_member.save
      check_if_both_are_ready
    else
      redirect_to league_path(@league), alert: "You must have 6 units on your current squad."
    end
  end

  def start
    @team_1 = @match.users.first.teams.find_by_league_id(params[:league_id])
    @team_2 = @match.users.last.teams.find_by_league_id(params[:league_id])

    @team_1.tokens.on_squad.each do |token|
      @match.match_tokens.create(:token => token, :side => 1)
    end

    @team_2.tokens.on_squad.each do |token|
      @match.match_tokens.create(:token => token, :side => 2)
    end

      #for now!
      simulate_match
      finish
  end

  def finish
    @match.finish

    @team_1.heal_bench_tokens
    @team_2.heal_bench_tokens

    @league.check_for_end_of_round
    redirect_to league_path(@league), notice: "The match has been finished."
  end

  private

  def check_squad_size
    team = current_user.teams.find_by_league_id(@league.id)

    if team.tokens.on_squad.length == 6
      true
    else
      false
    end
  end

  def check_if_both_are_ready
    ready = true
    @match.match_members.each do |member|
      ready = false if member.ready != true
    end

    start if ready
    redirect_to league_path(@league), notice: "Waiting for your opponent to be ready." if !ready
  end

  def simulate_match
    @match.tokens.each do |token|
      soldier = token.units.first.soldiers.first
      soldier.damage = soldier.damage + rand(0..2)
      soldier.save
    end
    winning_member = roto_winner
    winning_member.winner = true
    winning_member.save
  end

  def roto_winner
    #initialize variables
    team_1_aim = @team_1.total_stat('aim')
    team_1_stealth = @team_1.total_stat('stealth')
    team_1_speed = @team_1.total_stat('speed')
    team_1_sight = @team_1.total_stat('sight')
    team_1_hardiness = @team_1.total_stat('effective_hardiness')

    team_2_aim = @team_2.total_stat('aim')
    team_2_stealth = @team_2.total_stat('stealth')
    team_2_speed = @team_2.total_stat('speed')
    team_2_sight = @team_2.total_stat('sight')
    team_2_hardiness = @team_2.total_stat('effective_hardiness')

    #compares each category
    @team_1_roto_points = 0
    @team_2_roto_points = 0
    head_to_head(team_1_aim, team_2_aim)
    @match.log("#{@team_1.name} Aim: #{team_1_aim/100}")
    @match.log("#{@team_2.name} Aim: #{team_2_aim/100}")
    head_to_head(team_1_stealth, team_2_stealth)
    @match.log("#{@team_1.name} Stealth: #{team_1_stealth/100}")
    @match.log("#{@team_2.name} Stealth: #{team_2_stealth/100}")
    head_to_head(team_1_speed, team_2_speed)
    @match.log("#{@team_1.name} Speed: #{team_1_speed/100}")
    @match.log("#{@team_2.name} Speed: #{team_2_speed/100}")
    head_to_head(team_1_sight, team_2_sight)
    @match.log("#{@team_1.name} Sight: #{team_1_sight/100}")
    @match.log("#{@team_2.name} Sight: #{team_2_sight/100}")
    head_to_head(team_1_hardiness, team_2_hardiness)
    @match.log("#{@team_1.name} Hardiness: #{team_1_hardiness/100}")
    @match.log("#{@team_2.name} Hardiness: #{team_2_hardiness/100}")

    @match.log("#{@team_1.name} wins #{@team_1_roto_points} Categories")
    @match.log("#{@team_2.name} wins #{@team_2_roto_points} Categories")
    if @team_1_roto_points > @team_2_roto_points
      winner = @match.match_members.first
    else
      winner = @match.match_members.last
    end
  end

  def head_to_head (team_1_stat, team_2_stat)
    #comparison totals the roto_points
    if team_1_stat > team_2_stat
      @team_1_roto_points += 1
    elsif team_2_stat > team_1_stat
      @team_2_roto_points +=1
    else
      #coin flip for tie breaker. This should be rare, since stats are out to 2 decimals.
      if Random.rand(1..2) == 1
        @team_1_roto_points += 1
        @match.log("Team 1 wins tie-breaker")
      else
        @team_2_roto_points +=1
        @match.log("Team 2 wins tie-breaker")
      end
    end
end
end
