json.left do
  json.name  @left.to_s
  json.value @left.value
  json.unit  @left.unit.to_s
end
json.right do
  json.name  @right.to_s
  json.value @right.value
  json.unit  @right.unit.to_s
end
json.operator @operator.to_s
json.result do
  json.name  @result.to_s
  json.value @result.value
  json.unit  @result.unit.to_s
end
