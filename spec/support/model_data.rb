# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com

module ModelData
  def self.user(attr = {})
    User.create!({
      :first_name            => "Boris",
      :last_name             => "Barroso",
      :email                 => "boris@example.com",
      :phone                 => "2755620",
      :mobile                => "70681101",
      :website               => "http://boliviaonrails.com",
      :password              => "demo123",
      :password_confirmation => "demo123",
      :description           => "Una descripción"
    }.merge(attr) )
  end

  def self.country( attr = {}) 
    Country.create!({
      :name         => "Boliva",
      :abbreviation => "bo",
      :taxes        => []
    }.merge(attr) )
  end

end
