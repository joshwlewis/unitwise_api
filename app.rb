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
      Unitwise.search(params[:q] || '').map do |u|
        %i{primary_code secondary_code names slugs symbol}.reduce([]) do |arr,attr|
          arr + Array(u.send(attr))
        end
      end.to_json
    end

    post '/calculations', provides: 'json' do
      json     = request_json
      @operator = %w{convert_to + - * /}.find{ |o| o == json['operator'] }
      @left    = Unitwise(json['left']['value'] || 1, json['left']['unit'])
      @right   = Unitwise(json['right']['value'] || 1, json['right']['unit'])
      @result  = @left.send(@operator, @right)
      jbuilder :calculation
    end
  end
end
