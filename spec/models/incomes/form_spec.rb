require 'spec_helper'

# encoding: utf-8
describe Incomes::Form do
  let(:details) {
    [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
     {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
    ]
  }
  let(:item_ids) { details.map {|v| v[:item_id] } }

  let(:total) { 500 }
  let(:details_total) { details.inject(0) {|s, v| s+= v[:quantity] * v[:price] } }

  let(:contact) { build :contact, id: 1 }

  let(:today) { Time.zone.now.to_date }

  let(:valid_params) { {
      date: today, due_date: (today + 3.days), contact_id: 1,
      currency: 'BOB', bill_number: "I-0001", description: "New income description",
      income_details_attributes: details
    }
  }

  before(:each) do
    UserSession.user = build :user, id: 10
    OrganisationSession.organisation = build :organisation, currency: 'BOB', inventory: true
  end

  context "Initialization" do
    subject { Incomes::Form.new_income(valid_params) }

    it "income_details" do
      subject.income.should be_is_a(Income)
      subject.date.should be_is_a(Date)
      subject.due_date.should be_is_a(Date)
      subject.currency.should eq('BOB')
      subject.direct_payment.should eq(false)
      subject.income.income_details.size.should eq(2)

      subject.income.income_details[0].item_id.should eq(details[0][:item_id])
      subject.income.income_details[0].description.should eq(details[0][:description])
      subject.income.income_details[0].price.should eq(details[0][:price])
      subject.income.income_details[0].quantity.should eq(details[0][:quantity])
      subject.income.income_details[1].item_id.should eq(details[1][:item_id])
      subject.should respond_to(:details)
      subject.should respond_to(:income_details)
      subject.should respond_to(:income_details_attributes)

      subject.form_details_name.should eq('incomes_form[income_details_attributes]')
    end

    it "sets_defaults if nil" do
      is = Incomes::Form.new_income
      is.income.ref_number.should =~ /I-\d{2}-000\d/
      is.income.currency.should eq('BOB')
      is.income.date.should eq(Date.today)
    end
  end

  context "Validation" do
    it "#valid?" do
      is = Incomes::Form.new_income(account_to_id: 2, direct_payment: "1")

      is.should_not be_valid
      Accounts::Query.any_instance.stub_chain(:money, where: [( build :cash, id: 2 )])

      is = Incomes::Form.new_income(account_to_id: 2, direct_payment: "1")
      is.details.size.should eq(2)
      is.details.map(&:quantity).should eq([1,1])
    end

    it "unique items" do
      is = Incomes::Form.new_income(income_details_attributes: [
        {item_id: 1, quantity: 10, price: 1}, {item_id: 2, quantity: 10, price: 3},
        {item_id: 1, quantity: 3, price: 5}
      ])
      Accounts::Query.any_instance.stub_chain(:money, where: [( build :cash, id: 2 )])
      IncomeDetail.any_instance.stub(item: true)

      is.should_not be_valid
      is.errors[:base].should eq([I18n.t("errors.messages.item.repeated_items")])
      is.income.income_details[0].errors.should be_blank
      is.income.income_details[1].errors.should be_blank
      is.income.income_details[2].errors[:item_id].should eq([I18n.t("errors.messages.item.repeated")])
    end
  end

  context "Create a income with default data" do
    before(:each) do
      Income.any_instance.stub(valid?: true, contact: contact)
      IncomeDetail.any_instance.stub(valid?: true)
    end

    subject { Incomes::Form.new_income(valid_params) }

    it "creates and sets the default states" do
      s = double
      s.should_receive(:pluck).with(:id, :price).and_return([[1, 10.5], [2, 20.0]])

      Item.should_receive(:where).with(id: item_ids).and_return(s)

      # Create
      subject.create.should eq(true)

      # Income
      i = subject.income
      i.should be_is_a(Income)
      i.should be_is_draft
      i.should be_active
      i.inventory.should eq(true)
      i.ref_number.should =~ /I-\d{2}-\d{4}/
      i.date.should be_is_a(Date)
      i.error_messages.should eq({})

      i.creator_id.should eq(UserSession.id)
      #i.balance_inventory.should == 500

      # Number values
      i.exchange_rate.should == 1
      i.total.should == total

      #i.gross_total.should == (10 * 10.5 + 20 * 20.0)
      i.balance.should == total
      #i.gross_total.should > i.total

      #i.discount == i.gross_total - total
      #i.should be_discounted

      i.income_details[0].original_price.should == 10.5
      i.income_details[0].balance.should == 10.0
      i.income_details[1].original_price.should == 20.0
      i.income_details[1].balance.should == 20.0
    end

    it "creates and approves" do
      # Create
      subject.create_and_approve.should eq(true)

      # Income
      i = subject.income
      i.should be_is_a(Income)
      i.should be_is_approved
      i.should be_active

      i.date.should eq(today)
      i.due_date.should eq(valid_params.fetch(:due_date))

      i.approver_id.should eq(UserSession.id)
      i.approver_datetime.should be_is_a(Time)
    end
  end

  context "Update" do
    before(:each) do
      Income.any_instance.stub(valid?: true)
      IncomeDetail.any_instance.stub(valid?: true)
      ConciliateAccount.any_instance.stub(account_to: double(save: true, :amount= => true, amount: 1))
    end

    let(:subject) do
      inc = Incomes::Form.new_income(valid_params)
      inc.create
      inc
    end

    let(:update_details) {
      subject.details.map {|det|
        {id: det.id, item_id: det.item_id, quantity: det.quantity + 2, price: det.price}
      }
    }

    let(:total_for_update) { subject.total + 10 * 2 + 20 * 2 }
    let(:attributes_for_update) {
      valid_params.merge(total: total_for_update,
                         description: 'A new changed description', income_details_attributes: update_details)
    }


    it "does not allow errors on IncomeDetail" do
      i = subject.income
      is = Incomes::Form.find(i.id)
      is.income.stub(valid?: false)
      is.details[0].errors.add(:quantity, "Error in quantity")

      is.update.should eq(false)
      is.income.details[0].errors[:quantity].should eq(["Error in quantity"])
    end

    it "Stores with error if details has negative balance" do
      i = subject.income
      id = i.income_details[0]
      id.balance = 0
      id.save.should eq(true)

      is = Incomes::Form.find(i.id)
      is.income.should be_is_a(Income)
      is.service.should be_is_a(Incomes::Service)
      is.update(income_details_attributes: [
          {id: id.id, price: id.price, item_id: id.item_id, quantity: (id.quantity - 1) }
      ]).should eq(true)

      i = Income.find(is.income.id)

      i.should be_has_error
      i.error_messages.should eq({'items' => ['movement.negative_item_balance']})
    end

    it "udpates balance_inventory" do
      i = subject.income
      i.details[0].balance.should == 10
      i.details[1].balance.should == 20
      i.balance_inventory.should == 500

      incf = Incomes::Form.find(i.id)
      id = incf.details[0].id

      incf.update(income_details_attributes: [
        {id: id, item_id: 1, price: 10, quantity: 12},
        {item_id: 100, price: 10, quantity: 10}
      ]
      ).should eq(true)

      i = Income.find(incf.income.id)

      i.details.size.should eq(3)

      i.details.map(&:item_id).sort.should eq([1, 2, 100])

      i.details[0].quantity.should == 12
      i.details[0].balance.should == 12

      i.balance_inventory.should == 620
    end

    it "Update" do
      i = subject.income
      is = Incomes::Form.find(i.id)
      # Update
      is.update(attributes_for_update.merge(contact_id: 10)).should eq(true)
      # Income
      i = is.income
      i.should be_is_draft
      i.contact_id.should eq(1) # Does not change contact for update
      i.description.should eq('A new changed description')
      i.total.should == total_for_update

      i.income_details.size.should eq(2)
      i.income_details[0].quantity.should == 12
      i.income_details[1].quantity.should == 22

      #is.service.movement_history.should be_persisted
    end

    it "Direct payment" do
      AccountLedger.any_instance.stub(valid?: true)
      is = Incomes::Form.find(subject.income.id)
      is.stub(account_to: true)

      is.update_and_approve({direct_payment: true, account_to_id: 1}).should eq(true)

      is.income_id.should eq(is.income.id)
      # Income
      income = is.income
      income.total.should == 500.0
      income.should be_persisted
      income.id.should be_is_a(Integer)
      income.should be_is_paid
      income.balance.should == 0
      income.currency.should eq('BOB')

      ledger  = is.service.ledger
      ledger.amount.should == income.total
      ledger.should be_persisted
      ledger.account_id.should eq(income.id)
      ledger.currency.should eq('BOB')
      ledger.should be_is_payin
      ledger.exchange_rate.should == 1
      ledger.should be_is_approved
      ledger.contact_id.should eq(income.contact_id)

      ledger.status.should eq('approved')
      ledger.approver_id.should be_is_a(Integer)
    end

    it "update_and_approve" do
      i = subject.income
      is = Incomes::Form.find(i.id)

      is.update({}).should eq(true)
      is.income.should be_is_draft

      is = Incomes::Form.find(i.id)
      is.update_and_approve({})
      is.income.should be_is_approved
    end
  end

  describe "direct_payment" do
    before(:each) do
      AccountLedger.any_instance.stub(valid?: true)
      Income.any_instance.stub(valid?: true)
      IncomeDetail.any_instance.stub(valid?: true)
      Item.stub_chain(:where, pluck: [[1, 10], [2, 20.0]])
      ConciliateAccount.any_instance.stub(account_to: double(save: true, :amount= => true, amount: 1))
    end

    it "creates and pays" do
      is = Incomes::Form.new_income(valid_params.merge(direct_payment: "1", account_to_id: "2", reference: 'Recibo 123'))
      is.stub(account_to: true)

      is.create_and_approve.should eq(true)

      is.service.ledger.should be_is_a(AccountLedger)
      # ledger
      ledger = is.service.ledger
      ledger.account_id.should be_is_a(Integer)
      ledger.should be_persisted
      ledger.account_to_id.should eq(2)
      ledger.should be_is_payin
      ledger.amount.should == 500.0
      ledger.reference.should eq('Recibo 123')

      # income
      is.income.total.should == 500.0
      is.income.balance.should == 0.0
      #is.income.discount.should == 10.0
      is.income.should be_is_paid
    end

    it "updates and pays" do
      is = Incomes::Form.new_income(valid_params)
      is.create.should eq(true)
      is.income.should be_persisted
      inc = is.income
      #inc.should be_discounted
      #inc.discount.should == 10

      is = Incomes::Form.find(inc.id)
      is.income.should eq(inc)

      is.ref_number.should eq(inc.ref_number)
      is.total.should == total

      is.stub(account_to: true)
      is.update_and_approve(direct_payment: "1", account_to_id: "2", total: 500).should eq(true)

      is.service.ledger.should be_is_a(AccountLedger)
      # ledger
      ledger = is.service.ledger
      ledger.account_id.should be_is_a(Integer)
      ledger.account_to_id.should eq(2)
      ledger.reference.should eq("Cobro ingreso #{inc}")
      ledger.date.to_date.should eq(is.date)
      ledger.should be_is_payin
      ledger.amount.should == is.income.total

      # income
      is.income.should be_is_paid
      is.income.total.should == 500.0
      is.income.balance.should == 0.0
      #is.income.should_not be_discounted
      #is.income.discount.should == 0

      # UPDATE and check errors
      attrs = is.income.details.map {|det|
        {id: det.id, item_id: det.item_id, quantity: det.quantity - 2, price: det.price}
      }

      is = Incomes::Form.find(is.income.id)
      is.update(income_details_attributes: attrs).should eq(true)
      is.income.error_messages.should eq({"balance" => ["movement.negative_balance"]})
      is.income.should be_has_error

      is.income.total.should == 10 * 8 + 20 * 18

      attrs = is.income.details.map { |det|
        {id: det.id, item_id: det.item_id, quantity: det.quantity + 2, price: det.price}
      }
      is = Incomes::Form.find(is.income.id)
      is.update(income_details_attributes: attrs).should eq(true)
      is.income.should_not be_has_error
      is.income.error_messages.should eq({})

      # remove item
      det = is.income.details[0]
      attrs = [{id: det.id,_destroy: '1'}]
      is = Incomes::Form.find(is.income.id)
      is.update(income_details_attributes: attrs).should eq(true)

      is.income.error_messages.should eq({"balance" => ["movement.negative_balance"]})
      is.income.should be_has_error

      is.income.balance.should == -100
      is.income.total.should == 400
    end
  end

  it "sets errors from income or ledger" do
    is = Incomes::Form.new_income(direct_payment: true)

    is.create.should eq(false)
    is.should_not be_direct_payment
    is.errors.messages[:contact_id].should_not be_blank
  end

  describe "change of currency, inventory state" do
    before(:each) do
      Income.any_instance.stub(contact: contact)
      IncomeDetail.any_instance.stub(valid?: true)
    end

    it "change of currency" do
      is = Incomes::Form.new_income(valid_params)
      is.create_and_approve.should eq(true)

      is = Incomes::Form.find(is.income.id)

      details = is.income.details.map {|v| {id: v.id, item_id: v.item_id, price: v.price/2, quantity: v.quantity }}

      is.update({exchange_rate: 2, currency: 'USD',
                 income_details_attributes: details
      }).should eq(true)

      is.income.total.should eq(250)
      is.income.exchange_rate.should eq(2)
      is.income.currency.should eq('USD')

      Income.any_instance.stub(ledgers: [build(:account_ledger)])

      is = Incomes::Form.find(is.income.id)

      is.update({exchange_rate: 1, currency: 'BOB'}).should eq(false)
      is.errors[:currency].should eq([I18n.t('errors.messages.movement.currency_change')])
    end

    it "inventory_state" do
      is = Incomes::Form.new_income(valid_params)
      is.create_and_approve.should eq(true)

      is.income_details.each {|v| v.update_column(:balance, 0) }

      is = Incomes::Form.find(is.income.id)
      is.update.should eq(true)
      is.income.should be_delivered

      is.income_details[0].update_column(:balance, 1)
      is = Incomes::Form.find(is.income.id)
      is.update.should eq(true)
      expect(is.income).not_to be_delivered
    end
  end

  describe 'tax' do
    let(:tax) { create :tax, percentage: 10 }
    before(:each) do
      Income.any_instance.stub(valid?: true, contact: contact)
      IncomeDetail.any_instance.stub(valid?: true)
    end

    it "creates tax_in_out=false" do
      ifrm = Incomes::Form.new_income(valid_params.merge(tax_id: tax.id, tax_in_out: false))
      ifrm.create.should eq(true)

      tax.percentage.should == 10
      inc = ifrm.income
      inc.tax_in_out.should eq(false)
      inc.tax_percentage.should == 10
      inc.total.should == 550
    end

    it "creates tax_in_out=true" do
      ifrm = Incomes::Form.new_income(valid_params.merge(tax_id: tax.id, tax_in_out: true))
      ifrm.create.should eq(true)

      tax.percentage.should == 10
      inc = ifrm.income
      inc.tax_in_out.should eq(true)
      inc.tax_percentage.should == 10
      inc.total.should == 500
    end
  end

  describe 'Change state' do
    let(:tax) { create :tax, percentage: 10 }

    before(:each) do
      AccountLedger.any_instance.stub(valid?: true)
      Income.any_instance.stub(valid?: true)
      IncomeDetail.any_instance.stub(valid?: true)
      Item.stub_chain(:where, pluck: [[1, 10], [2, 20.0]])
      ConciliateAccount.any_instance.stub(account_to: double(save: true, :amount= => true, amount: 1))
    end

    it 'updates state' do
      is = Incomes::Form.new_income(valid_params.merge(direct_payment: "1", account_to_id: "2", reference: 'Recibo 123'))
      is.stub(account_to: true)

      is.create_and_approve.should eq(true)

      is.income.should be_is_paid

      is = Incomes::Form.find(is.income.id)
      is.update(tax_id: tax.id).should eq(true)

      is.income.should be_is_approved

      is = Incomes::Form.find(is.income.id)
      is.update(tax_id: nil).should eq(true)

      is.income.should be_is_paid
    end
  end

  it "#income.inventory?" do
    OrganisationSession.stub(inventory?: false)
    inc = Incomes::Form.new_income
    expect(inc.income).not_to be_inventory
  end

  context 'with tags' do
    before(:each) do
      AccountLedger.any_instance.stub(valid?: true)
      Income.any_instance.stub(valid?: true)
      IncomeDetail.any_instance.stub(valid?: true)
      Item.stub_chain(:where, pluck: [[1, 10], [2, 20.0]])
    end

    it "#save with tags" do
      tag1 = create :tag
      tag2 = create :tag, name: 'tag 2'

      tag_ids = [tag1.id, tag2.id]

      is = Incomes::Form.new_income(valid_params.merge(tag_ids: tag_ids))
      is.stub(account_to: true)

      is.create_and_approve.should eq(true)

      inc = Income.find(is.income.id)
      expect(inc.tag_ids).to eq(tag_ids)
      
      expect(inc.tag_ids.size).to eq(2)
    end
  end
end
