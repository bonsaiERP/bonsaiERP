require 'spec_helper'

describe ControllerServiceSerializer do
  let(:contact) { build :contact, id: 10 }

  it "#default" do
    css = ControllerServiceSerializer.new(contact)
    css.to_json.should eq(contact.to_json(methods: [:errors, :to_s]))
  end

  it "#methods" do
    css = ControllerServiceSerializer.new(contact)
    css.to_json(methods: [:to_param]).should eq(contact.to_json(methods: [:to_param, :errors, :to_s]))
  end

  it "#only" do
    css = ControllerServiceSerializer.new(contact)
    css.to_json(only: [:matchcode, :created_at]).should eq(contact.to_json(methods: [:errors, :to_s], only: [:matchcode, :created_at]))

  end

  it "#except" do
    css = ControllerServiceSerializer.new(contact)
    css.to_json(except: [:matchcode, :created_at]).should eq(contact.to_json(methods: [:errors, :to_s], except: [:matchcode, :created_at]))

  end

  it "#destroyed?" do
    contact.stub(destroyed?: true)

    css = ControllerServiceSerializer.new(contact)
    json = JSON.parse(css.to_json)


    json["destroyed?"].should eq(true)
  end
end
