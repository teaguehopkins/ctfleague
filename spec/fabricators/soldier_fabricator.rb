Fabricator(:soldier) do
  unit {Fabricate(:unit)}
end

Fabricator (:unit) do
  token {Fabricate(:token)}
end
