require 'spec_helper'

describe MatchMailer do
  it "has match members" do
    match_mailer = MatchMailer.new()
    match_mailer.match_members.should be
  end
end
