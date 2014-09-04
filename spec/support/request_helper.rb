module Request
  extend self

  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end
end
