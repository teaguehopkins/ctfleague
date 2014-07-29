require 'spec_helper'

feature "Users draft soldiers" do
include EmailSpec::Helpers
include EmailSpec::Matchers
before do
  LeagueMailer.default_url_options = { :host => 'localhost' }
  DraftMailer.default_url_options = { :host => 'localhost' }
  MatchMailer.default_url_options = { :host => 'localhost' }
end

  scenario "completing a draft and playing a match" do
    @user1 = Fabricate(:user, username: "testuser1")
    @user2 = Fabricate(:user, username: "testuser2")
    in_browser(:one) do
      visit '/'
      click_link 'Sign In'
      fill_in 'Email', with: 'testuser1'
      fill_in 'Password', with: 'password'
      click_button 'Sign in'
      page.should have_content('Signed in successfully.')
      page.should_not have_link("I'm Ready")
      click_link 'New League'
      fill_in 'League Name', with: 'Test League'
      click_button 'create league'
      fill_in 'Team Name', with: 'A-Team'
      click_button 'create team'
      fill_in 'Enter player emails', with: 'testuser2@example.com'
      click_button 'Invite'
      @league_key = @user1.leagues.first.league_key
      @league_path = @user1.leagues.first.id
    end
    in_browser(:two) do
      visit '/'
      click_link 'Sign In'
      fill_in 'Email', with: 'testuser2'
      fill_in 'Password', with: 'password'
      click_button 'Sign in'
      page.should have_content('Signed in successfully.')
      page.should_not have_link("I'm Ready")
      visit '/leagues/' + @league_path.to_s
      page.should have_content('Join the League')
      fill_in 'Team Name', with: 'B-Team'
      fill_in 'League Key', with: @league_key
      click_button 'Join'
    end
    in_browser(:one) do
      click_link 'User'
      page.should have_content('League Name')
      click_link 'Test League'
      page.should have_content('Season 1')
      click_button 'Begin Season'
      @user1.leagues.first.drafts.first.tokens.length.should be(16)
      draft_button = first(:button, 'Draft')
      draft_button.click unless draft_button.nil?
    end
    in_browser(:two) do
      click_link 'User'
      click_link 'Test League'
      click_button 'View Draft'
      first(:button, 'Draft').click
      draft_button = first(:button, 'Draft')
      draft_button.click unless draft_button.nil?
    end
    while @user1.leagues.first.drafts.first.tokens.length > 0 do
      in_browser(:two) do
        visit current_path
        draft_button = first(:button, 'Draft')
        draft_button.click unless draft_button.nil?
        draft_button = first(:button, 'Draft')
        draft_button.click unless draft_button.nil?
      end
      in_browser(:one) do
        visit current_path
        draft_button = first(:button, 'Draft')
        draft_button.click unless draft_button.nil?
        draft_button = first(:button, 'Draft')
        draft_button.click unless draft_button.nil?
      end
    end
    #draft is now complete
    @user1.leagues.first.drafts.first.tokens.length.should be(0)
    in_browser(:one) do
      click_link 'User'
      click_link 'Test League'
      click_button 'View My Team'
      for i in 0..5
          first(:button, 'Add').click
      end
      first(:link, 'Test League').click
      click_button 'Ready'
    end
    in_browser(:two) do
      click_link 'User'
      click_link 'Test League'
      click_button 'View My Team'
      for i in 0..5
          first(:button, 'Add').click
      end
      first(:link, 'Test League').click
      click_button 'Ready'
    end
    in_browser(:one) do
      visit current_path
      @user1.memberships.first.league.matches.first.get_log.should_not be(nil)
      puts @user1.memberships.first.league.matches.first.get_log
      @user2.memberships.first.league.matches.first.get_log.should_not be(nil)
    end
    in_browser(:two) do
      click_link 'User'
      page.should have_content 'Delete'
      page.should_not have_link 'Delete'
    end
    in_browser(:one) do
      click_link 'User'
      page.should have_content 'Delete'
      page.should have_link 'Delete'
      page.should have_content 'Test League'
      click_link 'Delete'
      page.should_not have_content 'Test League'
    end
  end
end
