require 'test_helper'

class TestSimpleton < Minitest::Test
  def test_singleton_is_enumerable
    assert_kind_of Enumerable, UnitApi::Simpleton
  end

  def test_all_are_simpletons
    UnitApi::Simpleton.each do |s|
      assert_instance_of UnitApi::Simpleton, s
    end
  end

  def test_search_returns_matches
    results = UnitApi::Simpleton.search('mm')
    millimeter = UnitApi::Simpleton.find do |s|
      if s.prefix
        s.atom.primary_code == 'm' && s.prefix.primary_code == 'm'
      end
    end
    assert_includes results,  millimeter
  end

  def test_search_returns_no_matches
    assert_empty UnitApi::Simpleton.search('i like turtles')
  end
end
