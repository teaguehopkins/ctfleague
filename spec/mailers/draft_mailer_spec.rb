require "spec_helper"
require_relative "../../app/mailers/match_mailer"

describe DraftMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before do
    DraftMailer.default_url_options = { :host => 'localhost' }
  end

  #need to define draft fabricator
  let(:draft) { Fabricate(:draft) }
  let(:mail_start) { DraftMailer.draft_beginning_email(draft) }
  let(:mail_next) { DraftMailer.draft_turn_email(draft) }


  it "should be from no-reply@heavymetalalpha.herokuapp.com" do
    mail_start.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
    mail_next.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
  end

  it "should be sent to the user's email address" do
    mail_start.should deliver_to(draft.snake_positions.first.user.email&&draft.snake_positions.last.user.email)
    mail_next.should deliver_to(draft.snake_positions.first.user.email)
  end

  it "should have a subject line" do
    mail_start.should have_subject("The draft has begun!")
    mail_next.should have_subject("It is your turn in the draft!")
  end

  #need to rewrite this test to work with any host
  xit "should have a link to the site in it" do
    mail_start.should have_body_text("To log in to the site, just follow this link: " + host)
  end

  it "shouldn't have this text in it" do
    mail_start.should_not have_body_text("I'm a little teapot, short and stout")
    mail_next.should_not have_body_text("I'm a little teapot, short and stout")
  end
end
