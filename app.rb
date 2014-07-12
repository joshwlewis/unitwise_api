require 'rubygems'
require 'bundler'
ENV['RACK_ENV'] ||= 'development'
Bundler.require(:default, ENV['RACK_ENV'])

$: << File.expand_path('../app', __FILE__)

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

    use Rack::Cors do
      allow do
        origins(/localhost:\d+/, 'unitwise.org')
        resource('*', headers: :any, methods: [:get, :post])
      end
    end

    get '/units', provides: 'json' do
      units = Unitwise.search(params[:q] || '')
      units.map { |u| unit_attributes(u) }.to_json
    end

    post '/calculations', provides: 'json' do
      json     = request_json
      calc = {}
      calc[:operator] = %w{convert_to + - * /}.find{ |o| o == json['operator'] }
      calc[:left]     = Unitwise(json['left']['value'] || 1, json['left']['unit']['code'])
      calc[:right]    = Unitwise(json['right']['value'] || 1, json['right']['unit']['code'])
      calc[:result]   = calc[:left].send(calc[:operator], calc[:right])
      %i{left right result}.reduce({}) do |hash, key|
        hash[key]         = unit_attributes(calc[key])
        hash[key][:value] = calc[key].simplified_value
        hash[key][:unit]  = unit_attributes(calc[key].unit)
        hash
      end.merge(operator: calc[:operator]).to_json
    end

    helpers do
      def unit_attributes(unit)
        {
          code: unit.to_s(:primary_code),
          name: unit.to_s(:names),
          aliases: %i{primary_code secondary_code symbol}.map do |mode|
            unit.to_s(mode)
          end.compact.uniq
        }
      end
    end
  end
end
