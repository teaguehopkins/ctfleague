Fabricator(:match) do
  # match_members { 2.times.map { Fabricate(:match_member) } }
  match_members { [ Fabricate(:match_member),  Fabricate(:match_member, winner: true) ] }
end
