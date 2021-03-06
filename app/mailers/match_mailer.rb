class MatchMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def send_match_results_emails(match)
    @match_members = match.match_members
    #equivalent to @league = League.find(self.league_id)
    @league = match.league
    @match = match
    @log = match.get_log
    #@winner = @match_members.find(&:winner?).user
    @winner = @match.match_members.where(winner: true).first.user
    @match_members.each do |mm|
      @member = mm
      @user = @member.user
        if @match_members.first == @member
            @opponent = @match_members.last.user
        else #match_members.last == user
            @opponent = @match_members.first.user
        end
      @opponent_team = @opponent.teams.select{|team| team.league == @league}.first
      mail(to: @user.email, subject: 'Match Results!', host: 'heavymetalalpha.herokuapp.com').deliver
    end
  end
end
