require "spec_helper"
require_relative "../../app/mailers/match_mailer"

describe "Match results email" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before do
    MatchMailer.default_url_options = { :host => 'localhost' }
  end

  # These are another way of achieving the below
  # The below is more rspecy
  #
  # before do
  #   @match = Fabricate(:match)
  # end
  #
  # let(:match_with_winner) {
  #   m = Fabricate(:match)
  #   m.match_members.first.winner = true
  #   m
  # }

  let(:match) { Fabricate(:match) }
  let(:mail) { MatchMailer.send_match_results_emails(match) }

  xit "should be from no-reply@heavymetalalpha.herokuapp.com" do
    # could change state here, but since we want for all, I left the change in the fabricator
    # match.match_members.first.winner = true
    mail.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
  end

  xit "should be sent to the user's email address" do
    mail.should deliver_to(match.match_members.first.user.email&&match.match_members.last.user.email)
  end

  xit "should have a subject line" do
    mail.should have_subject("Match Results!")
  end

  xit "should tell who the match was between" do
    mail.should have_body_text("#{match.match_members.first.user.username}")
    mail.should have_body_text("#{match.match_members.last.user.username}")
  end

  xit "should correctly identify the winner" do
    mail.should have_body_text("The winner was #{match.match_members.last.user.username}")
  end

  #need to rewrite this test to work with any host
  xit "should have a link to the site in it" do
    mail.should have_body_text("To log in to the site, just follow this link: " + hostname)
  end

  xit "shouldn't have this text in it" do
    mail.should_not have_body_text("I'm a little teapot, short and stout")
  end

  xit "should have log of match events" do
    match.log("Event 1")
    match.log("Event 2")
    mail.should have_body_text("Event 1"&&"Event 2")
  end
end
