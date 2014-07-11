Fabricator(:match) do
  match_members!(count: 2) {Fabricate(:match_members)}
end
