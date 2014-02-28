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

    helpers do
      def request_json
        request.body.rewind
        ::JSON.parse(request.body.read)
      end
    end

    get '/units' do
      UnitApi::Simpleton.search(params[:search]).to_json
    end

    put '/conversions' do
      json = request_json
      source = Unitwise::Measurement.new(json['source']['value'], json['source']['unit'])
      target = Unitwise::Unit.new(json['target']['unit'])
      converted = source.convert(target)
      { source: source, target: converted }.to_json
    end

    put '/calculations' do
      json = request_json
      left = Unitwise(json['left']['value'], params['left']['unit'])
      right = Unitwise(params['left']['value'], params['right']['unit'])
      operator = %w{+ - * /}.find(json['operator'])
      left.send(operator, right).to_json
    end

  end
end

