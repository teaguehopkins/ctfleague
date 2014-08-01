# Deploy and rollback on Heroku in staging and production
#task :deploy_staging    => ['deploy:set_staging_app',
#                            'deploy:push',
#                            'deploy:migrate',
#                            'deploy:restart']
desc "Deploy to production & Migrate DB, after checking tests."
task :deploy => ['deploy:set_production_app',
                            'deploy:push',
                            'deploy:migrate',
                            'deploy:post_deploy',
                            'deploy:restart']

namespace :deploy do
  PRODUCTION_APP = 'heavymetalalpha'
#  STAGING_APP = 'YOUR_STAGING_APP_NAME_ON_HEROKU'

#  task :set_staging_app do
#    APP = STAGING_APP
#    BRANCH = 'development'
#  end

  task :set_production_app do
  	APP = PRODUCTION_APP
    BRANCH = 'master'
  end

  task :push do
    puts "Let's check your tests!"
    puts `rake db:migrate RAILS_ENV=test`

    if system 'bundle exec rspec --fail-fast'
      puts "Deploying #{BRANCH} to #{APP}..."
      #puts `git push -f git@heroku.com:#{APP}.git #{BRANCH}:master`
      puts `git push heroku master`
    else
      puts "FIX YOUR TESTS"
      fail
    end
  end

  task :restart do
    puts 'Restarting app servers...'
    run_clean "heroku restart --app #{APP}"
  end

  task :migrate do
    puts 'Running database migrations...'
    run_clean "heroku run rake db:migrate --app #{APP}"
  end

  task :off do
    puts 'Putting the app into maintenance mode...'
    run_clean "heroku maintenance:on --app #{APP}"
  end

  task :on do
    puts 'Taking the app out of maintenance mode...'
    run_clean "heroku maintenance:off --app #{APP}"
  end

  task :post_deploy do
    # NOTE: Tasks to be run when the app is deployed to production should be
    # put here
    #Rake::Task["data:preload"].invoke
  end

  def run_clean command
    Bundler.with_clean_env {
      puts `#{command}`
    }
  end
end
