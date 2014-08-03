class StatusMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def draft_status_emails()
    @leagues = League.all
    @leagues.each do |league|
      if league.drafting
        @league = league
        @draft = league.drafts.last
        @memberships = league.memberships
        @recent_picks = @draft.get_recent_picks
        @rounds_remaining = @draft.tokens.length / @memberships.length
        @current_position = @draft.current_position
        @current_snake_position = @draft.snake_positions.find_by position: @current_position
        @picking_user = @current_snake_position.user
        @memberships.each do |membership|
          @user = membership.user
          mail(to: @user.email, subject: league.name + ' - Status Update', host: 'heavymetalalpha.herokuapp.com').deliver
        end
      end
    end
  end

  def match_status_emails()
    @leagues = League.all
    @leagues.each do |league| #for each active or drafting league
      if !league.drafting && league.active
        @league = league
        @memberships = league.memberships
        @memberships.each do |membership| #for each user
          @user = membership.user
          @finished = true
          @user_ready = false
          @league.matches.active.each do |active_match| #for each active match
            active_match.match_members.each do |match_member| #for each member of an active match
              if match_member.user == @user #found the user in an active match
                if match_member.ready == true #the user is ready
                  @user_ready = true
                end
                if match_member.match.finished != true #the match is not finished (should always be true because match is active)
                  @finished = false
                end
              end
            end
          end
          mail(to: @user.email, subject: league.name + ' - Status Update', host: 'heavymetalalpha.herokuapp.com').deliver
        end
      end
    end
  end

end
