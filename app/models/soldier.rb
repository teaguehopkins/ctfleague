require 'faker'
require 'randomgaussian'

class Soldier < ActiveRecord::Base
  belongs_to :unit

  def set_starting_attributes
    self.xp = 0
    self.age = 18
    self.damage = 0
    self.rank = 1
    self.active = false
    self.first_name = Faker::Name.first_name
    self.last_name = Faker::Name.last_name
    self.aim = generate_stat
    self.stealth = generate_stat
    self.sight = generate_stat
    self.speed = generate_stat
    self.hardiness = generate_stat
    self.leadership = generate_stat
    self.save
  end

  def get_rank
    @ranks = Hash[1,"Private",
                  2,"Corporal",
                  3,"Sergeant",
                  4,"Staff Sergeant",
                  5,"Gunnery Sergeant",
                  6,"First Sergeant",
                  7,"Sergeant Major",
                  8,"Lieutenant",
                  9,"Captain",
                  10,"Major",
                  11,"Lt. Colonel",
                  12,"Colonel"]
    @ranks[self.rank]
  end

  def average
    #returns actual average, not average * 100
    (self.aim + self.sight + self.stealth + self.speed + self.hardiness + self.leadership)/600
  end

  def effective_hardiness
    truehard = self.hardiness - self.damage * 1000
    if truehard < 1
      truehard = 1
    end
    truehard
  end

  def effective_speed
    truespeed = self.speed - self.damage * 1000
    if truespeed < 1
      truespeed = 1
    end
    truespeed
  end

  def effective_stealth
    truestealth = self.stealth - self.damage * 1000
    if truestealth < 1
      truestealth = 1
    end
    truestealth
  end

  def effective_aim
    trueaim = self.aim - self.damage * 500
    if trueaim < 1
      trueaim = 1
    end
    trueaim
  end

  def age_up
    self.age = self.age + 1
    self.save
  end

  def check_for_retirement
    @factor = 0.6
    @agefactor = 0.9
    @rankfactor = 0.8
    #Percent chance of retiring = 1 - (factor ^ (age * agefactor - rank * rankfactor - 18)).
    @chance = 1 - (@factor**(self.age*@agefactor - self.rank * @rankfactor - 18))
    if @chance > rand
      self.retired = true
      self.save
      return true
    else 
      return false 
    end
  end

  def reset_match_stats
    self.spots = 0
    self.hits = 0
    self.kills = 0
    self.sneaks = 0
    self.grabs = 0
    self.captures = 0
    self.save
  end

  def spot
    self.spots += 1
    self.save
  end

  def hit
    self.hits += 1
    self.save
  end

  def kill
    self.kills += 1
    self.save
  end

  def sneak
    self.sneaks += 1
    self.save
  end

  def grab
    self.grabs += 1
    self.save
  end

  def capture
    self.captures += 1
    self.save
  end

  private

  def generate_stat
    rg = RandomGaussian.new(50,16)
    stat = rg.norminv
    stat = stat * 100
    if stat > 9900
      stat = 9900
    elsif stat < 100
      stat = 100
    end
    stat
  end
end
