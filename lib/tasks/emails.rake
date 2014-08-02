namespace :emails do
  desc "Send daily status emails"
  task :status => :environment do
    StatusMailer.draft_status_emails()
    StatusMailer.match_status_emails()
  end
end
