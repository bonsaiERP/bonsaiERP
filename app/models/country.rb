# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Country  < Struct.new(:code, :name)
  def to_s
    "#{name} #{code}"
  end

  class << self
    def find(cod)
      c = COUNTRIES[cod]
      Country.new(c.try(:fetch, :code), c.try(:fetch, :name))
    end

    def options
      all.map do |c|
        [c.to_s, c.code]
      end
    end

    def first
      find COUNTRIES.first[0]
    end

    def all
      @all ||= COUNTRIES.map do |k, v|
        Country.new(k, v.try(:fetch, :name))
      end
    end
  end
end
