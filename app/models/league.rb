class League < ActiveRecord::Base
  belongs_to :commissioner, :class_name => :User, :foreign_key => 'user_id'
  has_many :teams, dependent: :destroy
  has_many :seasons
  has_many :drafts
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :round_robins
  has_many :matches

  validates_presence_of :commissioner
  validates_uniqueness_of :name

  scope :active, -> { where(active: true) }

  after_create :generate_league_key

  def generate_round_robin
    @members = self.users.shuffle
    @round_robin = self.round_robins.create(:round => 1)

    position = 1
    @members.each do |member|
      @round_robin.round_robin_members.create(:user => member, :position => position)
      position = position + 1
    end

    generate_matches
  end

  def generate_matches
    @round_robin = self.round_robins.last
    @members = @round_robin.round_robin_members
    @length = @members.length

    @members.each do |member|
      if member.position <= (@length/2)
        @match = self.matches.create
        @match.season = self.season
        @match.users << member.user
        @match.users << @members.find_by_position(@length + 1 - member.position).user
        @match.save
      end
    end
  end

  def check_for_end_of_round
    @round_robin = self.round_robins.last

    end_of_round = true
    self.matches.each do |match|
      end_of_round = false if !match.finished
    end
    if end_of_round
      send_end_of_round_emails
      check_for_end_of_tournament
    end
  end

  def send_end_of_round_emails
    LeagueMailer.round_end_emails(self)
  end

  def check_for_end_of_tournament
    @round_robin = self.round_robins.last

    if @round_robin.round == (@round_robin.round_robin_members.length - 1)
      age_soldiers
      end_tournament
    else
      iterate_round_robin
      generate_matches
    end
  end

  def iterate_round_robin
    @members = @round_robin.round_robin_members

    @members.each do |member|
      if member.position > 1
        if member.position == @members.length
          member.position = 2
        else
          member.position = member.position + 1
        end
      end
      member.save
    end

    @round_robin.round = @round_robin.round + 1
    @round_robin.save
  end

  def age_soldiers
    #refactor this with get_all_soldiers?
    self.teams.each do |team|
      team.tokens.each do |token|
        soldier = token.units.first.soldiers.first
        soldier.age_up
        if (soldier.check_for_retirement)
          token.on_squad = false
          token.save
        end
      end
    end
  end

  def get_all_soldiers
    #returns array with all soldiers on teams in this league, or [] if no soldiers drafted yet
    @all_soldiers = []
    self.teams.each do |team|
      team.tokens.each do |token|
        @all_soldiers << token.units.first.soldiers.first
      end
    end
    @all_soldiers
  end


  def end_tournament
    self.season = self.season + 1
    self.active = false
    self.save
  end

  private

  def generate_league_key
    league_key = ('a'..'z').to_a.shuffle[0,8].join
    self.league_key = league_key
    self.save
  end
end
