class LeagueMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def invite_email(emails, league_id, league_key)
    @league_id = league_id
    @league_key = league_key
    mail(to: emails, subject: 'You\'ve been invited to a league!', host: 'heavymetalalpha.herokuapp.com')
  end
end
