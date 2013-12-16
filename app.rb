require "bundler"
Bundler.require

before do
  content_type 'application/json'
end

get '/' do
  "It's running. I need to put some kind of instructions here."
end

get '/atoms.json' do
  Unitwise::Atom.all.map do |a|
    { keys: [ a.names, a.primary_code, a.secondary_code, a.symbol].flatten.compact.uniq,
      dim: a.dim, property: a.property, classification: a.classification }
  end.to_json
end

get '/prefixes.json' do
  Unitwise::Prefix.all.map do |p|
    { keys: [ p.names, p.primary_code, p.secondary_code, p.symbol].flatten.compact.uniq,
      scalar: p.scalar }
  end.to_json
end
