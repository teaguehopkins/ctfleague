class LeagueMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def invite_email(emails, league)
    @league = league
    @league_id = league.id
    @league_key = league.league_key
    @commissioner = league.commissioner.username
    mail(to: emails, subject: @commissioner + ' invited you to a league!', host: 'heavymetalalpha.herokuapp.com')
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
