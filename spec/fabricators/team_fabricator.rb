Fabricator(:team) do
  name { sequence(:name) { |i| "team#{i}" } }
end
