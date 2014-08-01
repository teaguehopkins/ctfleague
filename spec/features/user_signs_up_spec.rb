require 'spec_helper'

feature "User signs up" do
  scenario "happy path" do
    visit '/'
    click_link "Sign In"
    click_link "Sign up"
    fill_in "Display Name", with: "joe"
    fill_in "Email", with: "joe@example.com"
    fill_in "Password", with: "mypassword", :match => :prefer_exact
    fill_in "Password confirmation", with: "mypassword"
    click_button "Sign up"
    page.should have_content "Welcome! You have signed up successfully."
    page.should_not have_link("Sign In")
    page.should have_link("Sign Out")

    click_link "Sign Out"
    click_link "Sign In"
    fill_in "Email", with: "joe@example.com"
    fill_in "Password", with: "mypassword"
    click_button "Sign in"
    page.should have_content "Signed in successfully."
  end

  scenario "signing in with username, rather than email" do
    Fabricate(:user, username: "joe")
    visit '/'
    click_link 'Sign In'
    fill_in 'Email', with: 'joe'
    fill_in 'Password', with: 'password'
    click_button 'Sign in'
    page.should have_content('Signed in successfully.')
    page.should_not have_link("I'm Ready")
  end

  scenario "failed login" do
    Fabricate(:user, username: "joe")
    visit '/'
    click_link 'Sign In'
    fill_in 'Email', with: 'joeieieie'
    fill_in 'Password', with: 'password'
    click_button 'Sign in'
    page.should have_content('Invalid email or password')
  end

  scenario "failed signup" do
    pending "Is it possible to test HTML 5 required this way?"
    Fabricate(:user, email: "joe@example.com", username: "joe")
    visit '/'
    click_link "I want to enlist!"
    fill_in "Email", with: "joe@example.com"
    fill_in "Username", with: "joe"
    fill_in "Password", with: "mypassword", :match => :prefer_exact
    fill_in "Password confirmation", with: "notthesame"
    # PR 1: Captchas
    click_button "Sign up"
    page.should_not have_content "Welcome to Squmblr"
    page.should have_content "Please review the problems below:"

    page.should have_error("has already been taken", on: "Email")
    page.should have_error("doesn't match Password", on: "Password confirmation")
    page.should have_error("has already been taken", on: "Username")
  end

  scenario "failed signup because invalid characters in username" do
    pending
    visit '/'
    click_link "I want to enlist!"
    fill_in "Email", with: "joe@example.com"
    fill_in "Username", with: "joe@example"
    fill_in "Password", with: "mypassword", :match => :prefer_exact
    fill_in "Password confirmation", with: "mypassword"
    click_button "Sign up"
    page.should_not have_content "Welcome to Squmblr"
    page.should have_content "Your account could not be created."
    page.should have_error("username can only contain letters", on: "Username")
  end

  scenario "failed signup because invalid characters in username" do
    pending
    visit '/'
    click_link "I'm Ready!"
    fill_in "Email", with: "joe@example.com"
    fill_in "Username", with: "joe joe"
    fill_in "Password", with: "mypassword", :match => :prefer_exact
    fill_in "Password confirmation", with: "mypassword"
    click_button "Sign up"
    page.should_not have_content "Welcome to Squmblr"
    page.should have_content "Your account could not be created."
    page.should have_error("username can only contain letters", on: "Username")
  end

  scenario "user receives welcome email" do
    pending
    # PR 2: Welcome Emails
  end
end
