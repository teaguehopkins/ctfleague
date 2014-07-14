require "spec_helper"

describe "Soldier" do
  let(:soldier) {Fabricate(:soldier)}

  it "should have a name" do
    soldier.set_starting_attributes
    soldier.first_name.should_not be(nil)
  end
end
