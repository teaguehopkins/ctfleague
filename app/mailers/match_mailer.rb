class MatchMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def send_match_results_emails(match)
    @match_members = match.match_members
    #equivalent to @league = League.find(self.league_id)
    @league = match.league
    @match = match
    @winner = @match_members.find(&:winner?)
    @match_members.each do |mm|
      @user = mm
        if @match_members.first == user
            @opponent = @match_members.last
        else #match_members.last == user
            @opponent = @match_members.first
        end
      mail(to: @member.email, subject: 'Match Results!', host: 'example.com')
    end
  end
end
