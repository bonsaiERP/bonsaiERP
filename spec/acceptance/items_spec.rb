# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Items", "I must be able to create and list items with prices" do
  background do
    set_organisation
  end

  scenario "Create a new item" do
    visit "/items"
    page.should have_css('a.new', :text => "Nuevo")

    click_link "Nuevo"

    fill_in "item[name]", :with => 'Pipocas'
    fill_in "item[code]", :with => 'PIP101'
    check "item[stockable]"
    choose 'item_product_true'
    fill_in "item[price]", :with => 25.00
    fill_in "item[discount]", :with => 5
    select "kg", :from => "item[unit_id]"
    fill_in "item[tag_list]", :with => 'grano, maiz, delicioso'
    fill_in "item[description]", :with => 'Grano de pipoca de alta calidad'
    click_button 'Salvar'

    page.should have_css('h1', :text => 'Ver item')
    page.should have_css('p', :text => 'Pipocas')
    page.should have_css('p', :text => 'PIP101')
    page.should have_css('p.stockable>span.true')
    page.should have_css('p.product>span.true')
    page.should have_css('p', :text => '25' )
    page.should have_css('p', :text => '0' )
    page.should have_css('p', :text => 'grano, maiz, delicioso')
    page.should have_css('p', :text => 'kilogramo')
  end

end
