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
      #token.set_x_location(0)
      @match.match_tokens.create(:token => token, :side => 1, :xloc => 0, :direction => 1, :flag => false, :spotted => false)
    end

    @team_2.tokens.on_squad.each do |token|
      #token.set_x_location(1000)
      @match.match_tokens.create(:token => token, :side => 2, :xloc => 1000, :direction => -1, :flag => false, :spotted => false)
    end

      @match.match_tokens.each do |match_token|
        match_token.token.units.first.soldiers.first.update active: true
      end
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

    @flagwinner = nil
    until @flagwinner != nil do
      @match.log("======================================= New Round =======================================")
      @match.match_tokens.sort { |a, b| b.init <=> a.init }.each do |match_token| #order tokens by speed
        vis = ""
        vis = "_____Vis" if match_token.spotted
        vis = vis + "_____Flag" if match_token.flag
        if match_token.side == 1 && match_token.soldier.active
          @match.log(match_token.soldier.last_name + " at " + match_token.xloc.to_s + " " + vis)
        end
        if match_token.side == 2 && match_token.soldier.active
          @match.log("_____________________________________________" + match_token.soldier.last_name + " at " + match_token.xloc.to_s + " " + vis)
        end
      end
    @match.log("--------------------------------------- Actions ---------------------------------------")
      sim_one_turn
    end
      @flagwinner.winner = true
      @flagwinner.save
  end

  def sim_one_turn
    @match.match_tokens.each do |match_token|
      if match_token.soldier.active
        match_token.check_sights
        if match_token.opponents_visible
          if match_token.can_hit(match_token.nearest_opponent)
            match_token.shoot(match_token.nearest_opponent)
            #puts match_token.soldier.last_name + " shoots."
          else
            match_token.run
            match_token.flag_grab
            flag_winner(match_token)
          end
        else
          #puts token.units.first.soldiers.first.last_name + " advances."
          match_token.run
          match_token.flag_grab
          flag_winner(match_token)
        end
      end
    end
  end

  def flag_winner(match_token)
    #check flag win conditions - does not handle ties
    if match_token.flag && match_token.xloc == 0 && match_token.side == 1
      @match.log(match_token.soldier.last_name + " has captured the flag!")
      @flagwinner = @match.match_members.where(user_id: @team_1.user.id).first
      @match.log(@team_1.name + " wins!")
    elsif match_token.flag && match_token.xloc == 1000 && match_token.side == 2
      @match.log(match_token.soldier.last_name + " has captured the flag!")
      @match.log(@team_2.name + " wins!")
      @flagwinner = @match.match_members.where(user_id: @team_2.user.id).first
    end

  end

end
