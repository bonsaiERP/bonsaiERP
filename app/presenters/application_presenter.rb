# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ApplicationPresenter
  def h
    Helper.instance
  end

  def currencies
    @currencies ||= Hash[Currency.scoped.values_of(:id, :symbol) ]
  end
end
