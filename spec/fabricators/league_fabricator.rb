Fabricator(:league) do
  commissioner {Fabricate(:user)}
  teams {[Fabricate(:team, name: "Red"), Fabricate(:team, name: "Blue")]}
end
