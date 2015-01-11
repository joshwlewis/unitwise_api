require 'test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    UnitApi::App
  end

  def test_units_index
    get '/units'
    assert last_response.ok?
    assert_kind_of String, last_response.body
  end

  def test_units_index_with_query
    get '/units', q: 'mm'
    assert last_response.ok?
    assert_includes last_response.body, 'millimeter'
  end

  def test_units_show
    get '/units/volt'
    assert last_response.ok?
    assert_includes last_response.body, 'Volt'
  end

  def test_conversions
    post '/calculations', { left: { value: '4', unit: { code: 'yard' }},
                            right: { unit: { code: 'm'} },
                            operator: 'convert_to' }.to_json
    assert last_response.ok?
    assert_equal 'm',    body['result']['unit']['code']
    assert_equal 3.6576, body['result']['value']
  end

  def test_calculations
    post '/calculations', { left:  { value: 12,  unit: { code: 'inch' } },
                            right: { value: 1, unit: { code: 'foot' } },
                            operator: '+' }.to_json
    assert_equal 'inch', body['result']['unit']['name']
    assert_equal 24,     body['result']['value']
  end


  private

  def body
    JSON.parse(last_response.body)
  end
end
