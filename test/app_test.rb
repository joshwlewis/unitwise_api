require 'test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    UnitApi::App
  end

  def test_units
    get '/units.json', q: 'mm'
    assert last_response.ok?
    assert_includes last_response.body, 'millimeter'
  end

  def test_conversions
    post '/calculations.json', { left: { value: 4, unit: 'yard' },
                                 right: { unit: 'm' },
                                 operator: 'convert_to' }.to_json
    assert last_response.ok?
    assert_equal 'm',   body['result']['unit']
    assert_equal 3.6576, body['result']['value']
  end

  def test_calculations
    post '/calculations.json', { left:  { value: 1,  unit: 'mile' },
                                 right: { value: 10, unit: 'km'  },
                                 operator: '+' }.to_json
    assert_equal body['result']['unit'], 'mile'
    assert_equal body['result']['value'], 7.213699494949495
  end


  private

  def body
    JSON.parse(last_response.body)
  end
end
