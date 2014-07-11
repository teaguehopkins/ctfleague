require "spec_helper"
require_relative "../../app/mailers/match_mailer"

describe "Match results email" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before do
    @user = Fabricate(:user)
    @match = Fabricate(:match)
    #@match_members = @match.match_members
    @match_members = [@user, Fabricate(:user)]
    @mail = MatchMailer.send_match_results_emails(@league, @user, @match_members, @match)
  end

  it "should be from no-reply@heavymetalalpha.herokuapp.com" do
    @mail.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
  end
  it "should be sent to the user's email address" do
    @mail.should deliver_to(@user.email)
  end
  it "should have a subject line" do
    @mail.should have_subject
  end
  it "should tell who the match was against" do
    @mail.should have_body_text("#{@user.username}")
    @mail.should have_body_text("#{@user.username}")
  end
  pending "should have a link to the site in it" do
    @mail.should have_body_text("To log in to the site, just follow this link: " + @url)
  end
  it "shouldn't have this text in it" do
    @mail.should_not have_body_text("I'm a little teapot, short and stout")
  end
end
