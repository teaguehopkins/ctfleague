class LeagueMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def invite_email(emails, league_id, league_key)
    @league_id = league_id
    @league_key = league_key
    mail(to: emails, subject: 'You\'ve been invited to a league!', host: 'heavymetalalpha.herokuapp.com')
  end

  def round_end_emails(league)
    @league = league
    @members = league.memberships
    @members.each do |member|
      @member = member
      mail(to: member.user.email, subject: 'Your round is complete', host: 'heavymetalalpha.herokuapp.com').deliver
    end
  end
end
