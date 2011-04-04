# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com

require "prawn/measurement_extensions"
class BasePdf < Prawn::Document
  include ActionView::Helpers::NumberHelper 

  def initialize
    #super :template => File.join(Rails.public_path, 'resources/seema_template.pdf'), :margin => [90, 20, 30] 
    @marg = 25
    @topmarg = 30
    @bottommarg = 38
    super :margin => [@topmarg.mm, @marg.mm, @bottommarg.mm, @marg.mm]
    font_size 9.5

    repeat :all do
      header
      #footer
    end
  end

  # Creates the header image
  def header
    #img_path = File.join(Rails.public_path, 'images/header_logo.jpg')
    x1, y1, x2, y2 = page.dimensions
    h = page.margins
    #image img_path, :width => 612, :fit => true, :at => [-h[:left], y2 - 105]
    org = OrganisationSession.current_organisaton
    bounding_box([300, y2 - 150], :width => 150, :height => 120) do
      text org.name, :style => :bold
      text org.address
    end
  end

  # Creates the footer with contact info
  def footer
    x1, y1, x2, y2 = page.dimensions
    pos_y = -5
    bounding_box([0, pos_y], :width => 150, :height => 120) do
      text "Seegräber GmbH\nTaunusstr. 3a\n65343 Eltville\nDeutschland", :size => 8.2
    end
    bounding_box([42.mm, pos_y], :width => 150, :height => 120) do
      text "Registergericht: Wiesbaden HRB 17635\nGeschäftsführer: Bernd Seegräber\nSt. Nr.: 3786900082", :size => 8.2
    end
    bounding_box([120.mm, pos_y], :width => 150, :height => 120) do
      text "Tel. +49 (0) 6123- 5021\nFax +49 (0) 6123- 5023\nE-Mail: info@seema.de", :size => 8.2
    end
  end

end
