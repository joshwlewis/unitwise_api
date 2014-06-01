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

    get '/units.json' do
      Unitwise.search(params[:q]).map do |u|
        %i{primary_code secondary_code names slugs symbol}.reduce([]) do |arr,attr|
          arr + Array(u.send(attr))
        end
      end.to_json
    end

    post '/conversions.json' do
      json = request_json
      @source = Unitwise::Measurement.new(json['source']['value'], json['source']['unit'])
      @target = Unitwise::Unit.new(json['target'])
      @result = @source.convert_to(@target)
      jbuilder :conversion
    end

    post '/calculations.json' do
      json     = request_json
      @left    = Unitwise(json['left']['value'], json['left']['unit'])
      @right   = Unitwise(json['right']['value'], json['right']['unit'])
      @operator = %w{+ - * /}.find{ |o| o == json['operator'] }
      @result  = @left.send(@operator, @right)
      jbuilder :calculation
    end
  end
end
