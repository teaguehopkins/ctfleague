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

      self.unit.token.on_squad = false
      self.unit.token.save
    end
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
