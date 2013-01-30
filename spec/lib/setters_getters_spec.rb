require 'spec_helper'

describe SettersGetters do
  subject {
    class Uno
      extend SettersGetters
    end
  }

  it "creates setters" do
    subject.create_setters("uno", "a").should eq([:uno=, :a=])
  end

  it "creates accessors" do
    subject.create_accessors("uno", "a").should eq([:uno, :a, :uno=, :a=])
  end
end
