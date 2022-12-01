require 'rubygems'
require 'bundler'
ENV['RACK_ENV'] ||= 'development'
Bundler.require(:default, ENV['RACK_ENV'])
$: << File.expand_path('../app', __FILE__)
$stdout.sync = true

redis_class = ENV['RACK_ENV'] == 'test' ? MockRedis : Redis
redis_args = ENV['REDIS_URL'] ? { url: ENV['REDIS_URL'] } : {}
redis = redis_class.new(redis_args)

# Setup the search suggestion engine
Suggestor = Mindtrick::Set.new(prefix: "units-#{ ENV['RACK_ENV'] }", redis: redis)

module UnitApi
  class App < Sinatra::Base
    before do
      content_type :json
    end

    use Rack::Cors do
      allow do
        origins(/localhost:\d+/, /(\w+\.)?unitwise.org/, 'joshwlewis.github.io')
        resource('*', headers: :any, methods: [:get, :post])
      end
    end

    get '/units', provides: 'json' do
      query = (params[:q] || '').strip
      Suggestor.seed(query) if Unitwise.valid?(query)
      count = query.empty? ? 50 : 10
      units = Suggestor.suggest(query, count).reduce([]) do |arr,s|
        arr << Unitwise::Unit.new(s) if Unitwise.valid?(s)
        arr
      end.uniq
      units.map { |u| unit_attributes(u) }.to_json
    end

    get '/units/:code', provides: 'json' do |code|
      if Unitwise.valid?(code)
        unit = Unitwise::Unit.new(code)
        %w{names primary_code symbol}.each do |a|
          Suggestor.add unit.to_s(a)
        end
        unit_attributes(unit).to_json
      else
        status 404
      end
    end

    post '/calculations', provides: 'json' do
      @operator = %w{convert_to + - * /}.find{ |o| o == request_json['operator'] }
      @left     = build_measurement('left')
      @right    = build_measurement('right')
      @result   = @left.send(@operator, @right)
      [:left, :right, :result].reduce({}) do |hash, key|
        measurement       = instance_variable_get("@#{key}")
        hash[key]         = unit_attributes(measurement)
        hash[key][:value] = measurement.simplified_value.to_f
        hash[key][:unit]  = unit_attributes(measurement.unit)
        hash
      end.merge(operator: @operator).to_json
    end

    helpers do
      def request_json
        request.body.rewind
        ::JSON.parse(request.body.read)
      end

      def build_measurement(key)
        Unitwise(get_value(key), get_unit_code(key))
      end

      def get_value(key)
        BigDecimal((request_json[key]['value'] || 1).to_s)
      end

      def get_unit_code(key)
        request_json[key]['unit']['code']
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
