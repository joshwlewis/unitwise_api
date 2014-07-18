require 'rubygems'
require 'bundler'
ENV['RACK_ENV'] ||= 'development'
Bundler.require(:default, ENV['RACK_ENV'])
$: << File.expand_path('../app', __FILE__)
$stdout.sync = true

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
      @operator = %w{convert_to + - * /}.find{ |o| o == json['operator'] }
      @left     = build_measurement('right')
      @right    = build_measurement('right')
      @result   = @left.send(@operator, @right)
      %i{left right result}.reduce({}) do |hash, key|
        measurement       = instance_variable_get("@#{key}")
        hash[key]         = unit_attributes(measurement)
        hash[key][:value] = measurement.simplified_value
        hash[key][:unit]  = unit_attributes(measurement.unit)
        hash
      end.merge(operator: @operator).to_json
    end

    helpers do
      def build_measurement(key)
        Unitwise(get_value(key), get_unit_code(key))
      end

      def get_value(key)
        BigDecimal((json[key]['value'] || 1).to_s)
      end

      def get_unit_code(key)
        json[key]['unit']['code']
      end

      def unit_attributes(unit)
        {
          name:           unit.to_s(:names),
          code:           unit.to_s(:primary_code),
          symbol:         unit.to_s(:symbol),
          dim:            unit.dim
        }
      end
    end
  end
end
