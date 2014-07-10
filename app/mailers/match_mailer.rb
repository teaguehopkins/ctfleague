class MatchMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def send_match_results_emails(league, member, match_members, match)
    @match_members = match_members
    @member = member
    @user = member.user
    @league = league
    @match = match
    if match_members.first == member
        @opponent = match_members.last.user
    else #match_members.last == user
        @opponent = match_members.first.user
    end

    if @member.winner == true
        @winner = @user
    else
        @winner = @opponent
    end

    mail(to: @user.email, subject: 'Match Results!', host: 'example.com')
  end

end
