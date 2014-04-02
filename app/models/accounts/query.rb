# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Accounts::Query
  def initialize(rel = Account)
    @rel = rel
  end

  def money
    @rel.active.where(type: %w(Bank Cash StaffAccount)).order(:type, :name)
  end

  def bank_cash
    @rel.active.where(type: %w(Bank Cash)).order(:type, :name)
  end

  def bank_cash_options(cur = OrganisationSession.currency)
    create_options(bank_cash)
  end

  def money_options(cur = OrganisationSession.currency)
    options = money
    options = options.where(currency: [cur, OrganisationSession.currency])  unless cur == OrganisationSession.currency

    blank + options.map { |v| create_hash(v, *default_options) }
  end

  def create_options(options)
    blank + options.map { |v| create_hash(v, *default_options) }
  end

  def money_options_minus(*ids)
    blank + money.where('id NOT in (?)', ids)
    .map { |v| create_hash(v, *default_options) }
  end

  def income_payment_options(income)
    bank_cash_options(income.currency) + expense_options(income)
  end

  def expense_options(income)
    options = Expense.approved.where(contact_id: income.contact_id)
    unless income.currency == OrganisationSession.currency
      options = options.where(currency: [income.currency, OrganisationSession.currency])
    end

    options.map { |v| create_hash(v, *default_options) }
  end

  def expense_payment_options(expense)
    money_options(expense.currency) + income_options(expense)
  end

  def income_options(expense)
    options = Income.approved.where(contact_id: expense.contact_id)
    unless expense.currency == OrganisationSession.currency
      options = options.where(currency: [expense.currency, OrganisationSession.currency])
    end

    options.map { |v| create_hash(v, *default_options) }
  end

  def create_hash(v, *args)
    h = Hash[args.map { |k| [k, v.send(k)] }]
    h[:text] = v.to_s
    h
  end

  def default_options
    [:id, :type, :currency, :amount, :name, :to_s]
  end

  def blank
    [{}]
  end

end
