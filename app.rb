require "bundler"
Bundler.require

before do
  content_type 'application/json'
end

get '/' do
  "It's running. I need to put some kind of instructions here."
end
