module UrlTools
  extend self

  def domain
    if Rails.env.development?
      'localhost.bom'
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
