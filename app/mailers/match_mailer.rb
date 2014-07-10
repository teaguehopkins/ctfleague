class MatchMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def send_match_results_emails(league, user, match_members, match)
    @match_member = match_member
    @user = user
    @league = league
    @match = match
    if match_members.first == user
        @opponent = match_members.last
    else #match_members.last == user
        @opponent = match_members.first
    end

    if user.winner
        @winner = @user
    else
        @winner = @opponent
    end

    mail(to: @member.email, subject: 'Match Results!', host: 'example.com')
  end

end
