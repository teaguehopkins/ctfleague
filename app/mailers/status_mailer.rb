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
    @leagues.each do |league|
      if !league.drafting && league.active
        @league = league
        @memberships = league.memberships
        @memberships.each do |membership|
          @user = membership.user
          @league.matches.active.each do |active_match|
            active_match.match_members.each do |match_member|
              if match_member.ready && match_member.user == @user
                @user_ready = true
              end
              if match_member.match.finished == true
                @finished = true
              end
            end
          end
          mail(to: @user.email, subject: league.name + ' - Status Update', host: 'heavymetalalpha.herokuapp.com').deliver
        end
      end
    end
  end

end
