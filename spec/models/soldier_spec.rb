require "spec_helper"

describe "Soldier" do
  let(:soldier) {Fabricate(:soldier)}

  it "should have a name" do
    soldier.set_starting_attributes
    soldier.first_name.should_not be(nil)
    soldier.last_name.should_not be(nil)
  end

  it "should always retire at 33 at rank 1" do
    soldier.set_starting_attributes
    soldier.age = 33
    soldier.check_for_retirement
    soldier.retired.should be(true)
  end

  it "should always retire at 39 at rank 8" do
    soldier.set_starting_attributes
    soldier.rank = 8
    soldier.age = 39
    soldier.check_for_retirement
    soldier.retired.should be(true)
  end

  it "should never retire at 20" do
    soldier.set_starting_attributes
    soldier.age = 20
    soldier.check_for_retirement
    soldier.retired.should be(nil)
  end

  it "should never retire at 30 and rank 12" do
    soldier.set_starting_attributes
    soldier.rank = 12
    soldier.age = 30
    soldier.check_for_retirement
    soldier.retired.should be(nil)
  end

end
