json.left do
  json.value @left.to_f
  json.unit  @left.unit.to_s
end
json.right do
  json.value @right.to_f
  json.unit  @right.unit.to_s
end
json.operator @operator.to_s
json.result do
  json.value @result.to_f
  json.unit  @result.unit.to_s
end
