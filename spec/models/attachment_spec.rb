require 'spec_helper'

describe Attachment do
  it { should belong_to(:attachable) }

  it { should validate_presence_of(:attachment) }
  it { should validate_presence_of(:position) }
  it { should validate_numericality_of(:position) }

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
     :small_attachment_url, :medium_attachment_url].each do |attr|
       _json.fetch(attr.to_s)
     end

     _json = at.as_json(only: [:id], methods: [])

     expect(_json).to eq({'id' => nil})

     _json = at.as_json(only: [:id, :name, :image])
     expect(_json).to eq({
       'id' => nil, 'name' => nil, 'image' => false,
       'attachment_url' => nil, 'attachment_remote_url' => nil,
       'small_attachment_url' => nil, 'medium_attachment_url' => nil})
  end

  context '#position' do
    let(:attachments) {
      3.times.map { |pos|
        a = build :attachment, position: pos + 1, name: "picture#{ pos  + 1 }.jpg"
        a.stub(valid?: true)
        a.save!
        a
      }
    }

    let(:at1) { attachments[0] }
    let(:at2) { attachments[1] }
    let(:at3) { attachments[2] }

    it "#move_up" do
      expect(at1.position).to eq(1)
      expect(at2.position).to eq(2)
      expect(at3.position).to eq(3)

      expect(at2.move_up(at1.position)).to eq(true)

      attachs = Attachment.order(:position)

      expect(attachs[0].id).to eq(at2.id)
      expect(attachs[0].position).to eq(1)

      expect(attachs[1].id).to eq(at1.id)
      expect(attachs[1].position).to eq(2)
      expect(attachs[2].id).to eq(at3.id)
      expect(attachs[2].position).to eq(3)

      # move up again
      expect(at2.move_up(0)).to eq(true)

      attachs = Attachment.order(:position)

      expect(attachs[0].id).to eq(at2.id)
      expect(attachs[0].position).to eq(1)

      expect(attachs[1].id).to eq(at1.id)
      expect(attachs[1].position).to eq(2)
      expect(attachs[2].id).to eq(at3.id)
      expect(attachs[2].position).to eq(3)
    end

    it "#move_up ERROR" do
      at2.stub(save: false)
      expect(at2.move_up(1)).to eq(false)

      attachs = Attachment.order(:position)

      expect(attachs[0].id).to eq(at1.id)
      expect(attachs[0].position).to eq(1)
      expect(attachs[1].id).to eq(at2.id)
      expect(attachs[1].position).to eq(2)
      expect(attachs[2].id).to eq(at3.id)
      expect(attachs[2].position).to eq(3)
    end

    it "#true for same position or greater" do
      expect(at2.move_up(at2.position)).to eq(true)

      attachs = Attachment.order(:position)
      expect(attachs[0].id).to eq(at2.id)
      expect(attachs[0].position).to eq(1)
      expect(attachs[1].id).to eq(at1.id)
      expect(attachs[1].position).to eq(2)
      expect(attachs[2].id).to eq(at3.id)
      expect(attachs[2].position).to eq(3)
    end

    it "#move_down" do
      expect(at2.move_down(at3.position)).to eq(true)

      attachs = Attachment.order(:position)

      expect(attachs[0].id).to eq(at1.id)
      expect(attachs[0].position).to eq(1)
      expect(attachs[1].id).to eq(at3.id)
      expect(attachs[1].position).to eq(2)

      expect(attachs[2].id).to eq(at2.id)
      expect(attachs[2].position).to eq(3)

      # move down again
      expect(at2.move_down(3)).to eq(true)

      attachs = Attachment.order(:position)

      expect(attachs[0].id).to eq(at1.id)
      expect(attachs[0].position).to eq(1)
      expect(attachs[1].id).to eq(at3.id)
      expect(attachs[1].position).to eq(2)

      expect(attachs[2].id).to eq(at2.id)
      expect(attachs[2].position).to eq(3)
    end

    it "#move_down ERROR" do
      at2.stub(save: false)
      expect(at2.move_down(3)).to eq(false)

      attachs = Attachment.order(:position)

      expect(attachs[0].id).to eq(at1.id)
      expect(attachs[0].position).to eq(1)
      expect(attachs[1].id).to eq(at2.id)
      expect(attachs[1].position).to eq(2)
      expect(attachs[2].id).to eq(at3.id)
      expect(attachs[2].position).to eq(3)
    end

    it "#move_down with same position" do
      expect(at2.move_down(2)).to eq(true)

      attachs = Attachment.order(:position)

      expect(attachs[0].id).to eq(at1.id)
      expect(attachs[0].position).to eq(1)
      expect(attachs[1].id).to eq(at3.id)
      expect(attachs[1].position).to eq(2)
      expect(attachs[2].id).to eq(at2.id)
      expect(attachs[2].position).to eq(3)
    end
  end
end
