Fabricator(:league) do
  commissioner {Fabricate(:user)}
end
