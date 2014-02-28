module UnitApi
  class Simpleton < Liner.new(:atom, :prefix)
    extend Enumerable

    def self.add(*args)
      simpleton = self.new(*args)
      if self.find { |s| s == new }
        false
      else
        self << simpleton
      end
    end

    def self.all
      @all ||= defaults
    end

    def self.<<(simpleton)
      @all << simpleton
    end

    def self.defaults
      defaults = []
      Unitwise::Atom.all.each do |a|
        defaults << self.new(a)
        if a.metric?
          Unitwise::Prefix.all.each do |p|
            defaults << self.new(a,p)
          end
        end
      end
      defaults
    end

    def self.each &block
      all.each do |simpleton|
        if block_given?
          block.call simpleton
        else
          yield simpleton
        end
      end
    end

    def self.search(term)
      self.all.select do |i|
        i.search_strings.any? { |string| string =~ /#{term}/i }
      end
    end

    def search_strings
      if prefix
        prefix.search_strings.zip(atom.search_strings).map{ |set| set.join '' }
      else
        atom.search_strings
      end
    end

    def to_json(*a)
      search_strings.to_json(*a)
    end
  end
end
