require "spec_helper"

describe "Match controller" do
  let(:match) {Fabricate(:match)}

  xit "should log results in match" do
    match.match_log.should be
  end

end
