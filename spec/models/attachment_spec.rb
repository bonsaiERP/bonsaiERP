require 'spec_helper'

describe Attachment do
  it { should belong_to(:attachable) }

  it { should validate_presence_of(:attachment) }

  context 'attachable' do
    subject { Attachment.new(attachable_id: 1, attachable_type: 'Item') }

    it "valid?" do
      expect(subject).to_not be_valid
      expect(subject.errors[:attachable]).to be_present
    end

    it "invalid attachable" do
      subject.attachable_type = ''

      expect(subject).to_not be_valid
      expect(subject.errors[:attachable]).to be_blank
    end
  end

  it "#extname" do
    at = Attachment.new(name: 'test.psd.jpg')

    expect(at.extname).to eq('.jpg')
  end


end
