require 'spec_helper'

describe ReportsController do
  it "#index" do
    get :index, report: 'items'
  end
end
