# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Organisations", "In order to create an organisation I must login" do

  background do
    UserSession.current_user = User.new(:first_name => 'Violeta', :last_name => 'Barroso') {|u| u.id = 1}
    create_countries
    create_currencies
  end

  scenario "Scenario create organisation" do

    o = Organisation.new(:name => 'Violetas', :currency_id => 1, :country_id => 1, 
                         :phone => '7881221', :mobile => '789123434',
                        :address => 'Mallasa calle 4 Nº 222', 
                        :preferences => {"open_prices" => "1", "item_discount" => "2", "general_discount" => "0.5" })

    o.save.should == true

    o.reload
    o.taxes.map(&:organisation_id).uniq.should == [o.id]
    o.units.map(&:organisation_id).uniq.should == [o.id]

    o.due_date.should == 30.days.from_now.to_date
    o.links.first.user_id.should == 1
    o.links.first.creator.should == true

    # Preferences
    o.preferences.should == {:open_prices => true, :item_discount => 2, :general_discount => 0.5 }

  end

end
