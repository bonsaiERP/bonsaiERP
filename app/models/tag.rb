# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Tag < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true,
            format: {with: /\A[^\s,]*\z/}

  validates :bgcolor, presence: {message: I18n.t('errors.messages.taken')},
            format: {with: /\A\#[0-9abcdefABCDEF]{6}\z/}

  def to_s
    name
  end
  alias :label :to_s

  # Updates multiple models
  def self.update_models(params)
    tag_ids = Tag.where(id: params[:tag_ids]).pluck(:id)
    klass = params[:model].constantize

    if tag_ids.any?
      klass.where(id: params[:ids]).update_all(["tag_ids='{?}'", tag_ids])
    else
      klass.where(id: params[:ids]).update_all("tag_ids='{}'")
    end
  end
end
