module UrlTools
  extend self

  def domain
    if Rails.env.development?
      unless UserSession.dev_domain.present?
        'lvh.me'
      else
        'localhost'
      end
    else
      DOMAIN
    end
  end

  def protocol
    if Rails.env.development?
      'http'
    else
      'http'
    end
  end
end
