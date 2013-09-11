# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Tag < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true,
            format: {with: /\A[^\s,]*\z/}

  validates :bgcolor, presence: {message: I18n.t('errors.messages.taken')},
            format: {with: /\A\#[0-9abcdefABCDEF]{6}\z/}
  validates_lengths_from_database

  scope :list, -> { select("id, name, bgcolor") }

  def to_s
    name
  end
  alias :label :to_s
  alias :text :to_s

  # Updates multiple models
  def self.update_models(params)
    tag_ids = Tag.where(id: params[:tag_ids]).pluck(:id)

    klass = get_model_class params[:model]
    return false  if klass === false

    if tag_ids.any?
      klass.where(id: params[:ids]).update_all(["tag_ids='{?}'", tag_ids])
    else
      klass.where(id: params[:ids]).update_all("tag_ids='{}'")
    end
  end

private
  def self.get_model_class(mod)
    case mod
    when 'Account' then Account
    when 'Income' then Income
    when 'Expense' then Expense
    when 'AccountLedger' then AccountLedger
    when 'Item' then Item
    else
      false
    end
  end
end
