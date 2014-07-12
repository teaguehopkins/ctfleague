Fabricator(:draft) do
  league {Fabricate(:league, name:"Test League")}
  available_tokens { 16.times.map {Fabricate(:available_token)}}
  snake_positions {[ Fabricate(:snake_position, position: 1),  Fabricate(:snake_position, position: 2) ] }
  current_position {1}
end
