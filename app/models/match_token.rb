class MatchToken < ActiveRecord::Base
  belongs_to :token
  belongs_to :match


=begin
  def get_x_location
    self.xloc
  end

  def set_x_location(x)
    self.xloc = x
    self.save
  end

=end

  def distance_to(token)
    dist = self.xloc - token.xloc
    dist.abs
  end

  def spot(target)
    target_soldier = target.token.units.first.soldiers.first
    self_soldier = self.token.units.first.soldiers.first
    distance_bonus = [0,(100 - 5 * self.distance_to(target))].max/100.0 + 1
    percentage = self_soldier.sight/100 * distance_bonus - target_soldier.effective_stealth/100
    roll = rand(1..100)
    spotted = roll < percentage
    #puts "Spot Check: " + roll.to_s + " " + percentage.to_s
    if spotted
      if target.spotted == false
        self.match.log(self_soldier.last_name + " spotted " + target_soldier.last_name)
        self.soldier.spot
      end
      target.spotted = true
      target.save
    end
    if spotted == false && self.distance_to(target) < 100 && target.spotted == false
      self.match.log(target.soldier.last_name + " (Stealth: "+ (target.soldier.effective_stealth/100).to_s + ")" + " snuck past " + self.soldier.last_name)
      target.soldier.sneak
    end
    spotted
  end

def check_sights()
  #returns array of enemy tokens this token can see
  opponent = 0
  if self.side == 1
    opponent = 2
  else
    opponent = 1
  end
  self.match.match_tokens.each do |target_match_token|
    if target_match_token.side == opponent && target_match_token.soldier.active #is an active enemy
      self.spot(target_match_token)
    end
  end
end

  def nearest_opponent
    #returns nearest active visible enemy match_token
    opponent = 0
    if self.side == 1
      opponent = 2
    else
      opponent = 1
    end
    nearest = nil
    distance = 1001
    self.match.match_tokens.each do |target_match_token|
      if target_match_token.side == opponent && target_match_token.spotted && target_match_token.soldier.active && (self.distance_to(target_match_token) < distance)
        nearest = target_match_token
        distance = self.distance_to(target_match_token)
      end
    end
    nearest
  end

  def hit_chance(target)
    target_soldier = target.soldier
    self_soldier = self.soldier
    distance_bonus = [0,(100 - 10 * self.distance_to(target))].max/100.0 + 1
    percentage = self_soldier.effective_aim/100 * distance_bonus - (target_soldier.effective_speed/200)
  end

  def can_hit(target)
    percentage = self.hit_chance(target)
    percentage > 25
  end

  def shoot(target)
    target_soldier = target.soldier
    self_soldier = self.soldier
    self.match.log(self_soldier.last_name + " shot at " + target_soldier.last_name)
    percentage = self.hit_chance(target)
    roll = rand(1..100)
    hit = roll < percentage
    #puts "Shot Check: " + roll.to_s + " " + percentage.to_s
    if hit
      if self.distance_to(target) < 300
        self.match.log(self_soldier.last_name + " hit " + target_soldier.last_name)
      else
        self.match.log(self_soldier.last_name + " sniped " + target_soldier.last_name + " at range: " + self.distance_to(target).to_s)
      end
      target_soldier.damage += 1
      self.match.log(target_soldier.last_name + " Damage: " + target_soldier.damage.to_s)
      target_soldier.save
      self.soldier.hit
      self.stun(target)
    end
    hit
  end

  def stun(target)
    target_soldier = target.token.units.first.soldiers.first
    self_soldier = self.token.units.first.soldiers.first
    power = 30 #TODO Make this pull from equipment
    percentage = 100 - (target_soldier.effective_hardiness/100 - power)
    roll = rand(1..100)
    stunned = roll < percentage
    if stunned
      self.match.log(self_soldier.last_name + " disabled " + target_soldier.last_name)
      self_soldier.kill
      target_soldier.active = false
      target_soldier.save
    end
    stunned
  end

  def run
    self.xloc += self.token.units.first.soldiers.first.effective_speed/100 * direction
    self.xloc = [self.xloc, 1000].min
    self.xloc = [self.xloc, 0].max
    #puts self.token.units.first.soldiers.first.last_name + " at " + self.xloc.to_s
  end

  def flag_grab
    match = self.match
    #check if a teammate has the flag
    teammate_has_flag = false
    self.match.match_tokens.each do |match_token|
      if match_token.side == self.side && match_token.flag == true && match_token.soldier.active
        teammate_has_flag = true
      end
    end

    if teammate_has_flag == false
      if (self.side == 1 && self.xloc == 1000) || (self.side == 2 && self.xloc == 0)
        self.flag = true
        match.log(self.token.units.first.soldiers.first.last_name + " grabbed the flag!")
        self.soldier.grab
        self.direction = self.direction * -1
      end
    end
  end

  def soldier
    self.token.units.first.soldiers.first
  end

  def init
    self.soldier.effective_speed
  end

  def opponents_visible
    opponent = 0
    visible = false
    if self.side == 1
      opponent = 2
    else
      opponent = 1
    end
    self.match.match_tokens.each do |target_match_token|
      if target_match_token.side == opponent && target_match_token.spotted && target_match_token.soldier.active #active enemy spotted
        visible = true
      end
    end
    visible
  end

end
