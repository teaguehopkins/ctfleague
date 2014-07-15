Fabricator(:league) do
  commissioner {Fabricate(:user)}
  name {"Test League"}
  teams {[Fabricate(:team, name: "Red", id: 1), Fabricate(:team, name: "Blue", id: 2)]}
  id {1}
end
