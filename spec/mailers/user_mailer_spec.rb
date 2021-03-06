require "spec_helper"
require_relative "../../app/mailers/user_mailer"

describe "Welcome email" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before do
    @user = Fabricate(:user)
    @mail = UserMailer.welcome_email(@user)
    @url = 'http://heavymetalalpha.herokuapp.com/users/sign_in'
  end

  it "should be from no-reply@heavymetalalpha.herokuapp.com" do
    @mail.should deliver_from("no-reply@heavymetalalpha.herokuapp.com")
  end
  it "should be sent to the user's email address" do
    @mail.should deliver_to(@user.email)
  end
  it "should have a subject line of 'Welcome to Heavy Metal'" do
    @mail.should have_subject("Welcome to Heavy Metal")
  end
  it "should actually welcome the user to Heavy Metal" do
    @mail.should have_body_text("Welcome to Heavy Metal, #{@user.username}!")
  end
  it "should have a link to the site in it" do
    @mail.should have_body_text("To log in to the site, just follow this link: " + @url)
  end
  it "shouldn't have this text in it" do
    @mail.should_not have_body_text("I'm a little teapot, short and stout")
  end
end
