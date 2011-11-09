# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrgCountry < ActiveRecord::Base

  set_table_name "countries"

  has_many :organisations

  validates_presence_of :name, :abbreviation

  serialize :taxes

  def to_s
    name
  end

  def self.create_base_data
    path = File.join(Rails.root, "db/defaults", "countries.yml")
    countries = YAML.load_file(path)
    countries.each do |coun|
      OrgCountry.create!(coun) {|cu| cu.id = coun["id"]}
    end
  end
end
