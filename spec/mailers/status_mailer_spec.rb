require "spec_helper"
require_relative "../../app/mailers/status_mailer"

describe StatusMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before do
    StatusMailer.default_url_options = { :host => 'localhost' }
  end

  #need to create more robust fixtures
  let(:league) {Fabricate(:league)}
  let(:mail_draft) { StatusMailer.draft_status_emails() }
  let(:mail_match) { StatusMailer.match_status_emails() }


  xit "should be from no-reply@heavymetalalpha.herokuapp.com" do
    mail_draft.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
    mail_match.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
  end

  xit "should be sent to the user's email address" do
    mail_draft.should deliver_to(draft.snake_positions.first.user.email&&draft.snake_positions.last.user.email)
    mail_match.should deliver_to(draft.snake_positions.first.user.email)
  end

  xit "should have a subject line" do
    mail_draft.should have_subject("The draft has begun!")
    mail_match.should have_subject("It is your turn in the draft!")
  end

  it "shouldn't have this text in it" do
    mail_draft.should_not have_body_text("I'm a little teapot, short and stout")
    mail_match.should_not have_body_text("I'm a little teapot, short and stout")
  end
end
