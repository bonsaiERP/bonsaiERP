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

  it "#as_json" do
    at = Attachment.new
    _json = at.as_json

    [:id, :name, :size, :image, :position, :attachment_uid,
     :small_attachment_uid,
     :medium_attachment_uid].each do |attr|
       _json.fetch(attr.to_s)
     end

     _json = at.as_json(only: [:id], methods: [])

     expect(_json).to eq({'id' => nil})

     _json = at.as_json(only: [:id, :name, :image])
     expect(_json).to eq({'id' => nil, 'name' => nil, 'image' => false, 'small_attachment_uid' => nil, 'medium_attachment_uid' => nil})
  end
end
