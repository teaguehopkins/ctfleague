class MatchMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  #does this accessor need to be here?
  attr_accessor :match_members, :user

  def send_match_results_emails(league, user, match_members, match)
    @match_members = match_members
    @user = user
    @league = league
    @match = match
    if @match_members.first == user
        @opponent = @match_members.last
    else #match_members.last == user
        @opponent = @match_members.first
    end

    @winner = @match_members.find(&:winner?)

    mail(to: @member.email, subject: 'Match Results!', host: 'example.com')
  end

end
