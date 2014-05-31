require 'test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    UnitApi::App
  end

  def test_units
    get '/units', q: 'mm', format: 'json'
    assert last_response.ok?
    assert_includes last_response.body, 'millimeter'
  end

  def test_conversions
    post '/conversions', { source: { value: 4, unit: 'yard' },
                           target: { unit: 'm' } }.to_json, format: 'json'
    assert last_response.ok?
    assert_equal 'm',                body['result']['unit']
    assert_equal 3.6576000000000004, body['result']['value']
  end

  def test_calculations
    post '/calculations', { left:  { value: 1,  unit: 'mile' },
                            right: { value: 10, unit: 'km'  },
                            operator: '+' }.to_json, format: 'json'
    assert_equal body['result']['unit'], 'mile'
    assert_equal body['result']['value'], 7.213699494949496
  end


  private

  def body
    JSON.parse(last_response.body)
  end
end
