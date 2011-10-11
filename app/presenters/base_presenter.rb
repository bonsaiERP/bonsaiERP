# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def currencies
    @currencies ||= Hash[Currency.scoped.values_of(:id, :symbol) ]
  end

private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def markdown(text)
    Redcarpet.new(text, :hard_wrap, :filter_html, :autolink).to_html.html_safe
  end
  
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

end
