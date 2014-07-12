require "spec_helper"
require_relative "../../app/mailers/match_mailer"

describe "Match results email" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

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

  it "should be from no-reply@heavymetalalpha.herokuapp.com" do
    # could change state here, but since we want for all, I left the change in the fabricator
    # match.match_members.first.winner = true
    mail.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
  end

  # I made it pending becuase I didn't create a user yet
  xit "should be sent to the user's email address" do
    mail.should deliver_to(@user.email)
  end

  it "should have a subject line" do
    mail.should have_subject
  end

  pending "should tell who the match was against" do
    @mail.should have_body_text("#{@user.username}")
    @mail.should have_body_text("#{@user.username}")
  end

  pending "should have a link to the site in it" do
    mail.should have_body_text("To log in to the site, just follow this link: " + @url)
  end

  it "shouldn't have this text in it" do
    mail.should_not have_body_text("I'm a little teapot, short and stout")
  end
end
