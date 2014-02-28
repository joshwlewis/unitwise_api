require 'test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    UnitApi::App
  end

  def test_units
    get '/units', search: 'mm', format: 'json'
    assert last_response.ok?
    assert_includes last_response.body, 'millimeter'
  end

  def test_conversions
    put '/conversions', { source: { value: 4, unit: 'yard' }, target: { unit: 'm' } }.to_json, format: 'json'
    assert last_response.ok?
    body = JSON.parse(last_response.body)
    puts body
    assert_equal '3.6576000000000004 m', body['target']
  end
end
