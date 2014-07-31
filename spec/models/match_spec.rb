require "spec_helper"

describe "Match" do
  let(:match) { Fabricate(:match) }
  let(:soldier) {Fabricate(:soldier)}

  it "should not promote with 0 xp" do
    soldier.set_starting_attributes
    match.send(:promote_soldier, soldier)
    soldier.rank.should be(1)
  end

  it "should promote soldiers who earn enough xp" do
    soldier.set_starting_attributes
    soldier.xp=1
    match.send(:promote_soldier, soldier)
    soldier.rank.should be(4)
    soldier.xp=7
    match.send(:promote_soldier, soldier)
    soldier.rank.should be(8)
    soldier.xp=3
    match.send(:promote_soldier, soldier)
    soldier.rank.should be(6)
    soldier.xp=13
    match.send(:promote_soldier, soldier)
    soldier.rank.should be(12)
  end

  it "should have a working match log" do
    match.log("First Event")
    match.log("Second Event")
    match.get_log.should eq(["First Event","Second Event"])
  end
end
