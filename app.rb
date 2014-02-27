require 'rubygems'
require 'bundler'
Bundler.require

$: << File.expand_path('../app', __FILE__)

require 'models/simpleton'

module UnitApi
  class App < Sinatra::Base
    before do
      content_type 'application/json'
    end
    
    get '/search.json' do
      simpletons = UnitApi::Simpleton.search(params[:term])
      simpletons.map(&:search_strings).to_json
    end
  end
end

