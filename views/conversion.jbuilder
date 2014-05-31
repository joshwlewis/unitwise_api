json.source do
  json.name  @source.to_s
  json.value @source.value
  json.unit  @source.unit.to_s
end
json.target @target.to_s
json.result do
  json.name  @result.to_s
  json.value @result.value
  json.unit  @result.unit.to_s
end
