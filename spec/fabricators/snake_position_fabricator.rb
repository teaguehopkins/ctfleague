Fabricator(:snake_position) do
  user {Fabricate(:user)}
  position {sequence(:position)}
end
