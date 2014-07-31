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
    @match.simulate
    finish
  end

  def finish
    @match.finish
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

    if ready
      @match.match_members.each do |member|
        member.ready = false
        member.save
      end
      start
    end

    if !ready
      if @match.match_log == [] #should always be true before a match begins
        redirect_to league_path(@league), notice: "Waiting for your opponent to be ready."
      else #this should only happen if the Ready button was already clicked for this match
        redirect_to league_path(@league), notice: "The match has been finished."
      end
    end
  end



end
