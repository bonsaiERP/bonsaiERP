module UrlTools
  extend self

  def domain
    if Rails.env.production?
      DOMAIN
    else
      'localhost.bom'
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
