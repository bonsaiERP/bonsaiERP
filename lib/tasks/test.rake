namespace :bonsai_test do
  desc 'Creates organisation and tenant'
  task create_tenant: :environment do
    Organisation.all.each do |org|
      org.drop_related!
    end

    r = Registration.new({name: 'bonsai', email: 'boris@bonsaierp.com',
     password: 'demo1234'})

    r.register
    u = r.user
    UserSession.user = u
    u.confirm_registration

    org = r.organisation
    org.update(country_code: 'BO', currency: 'BOB')

    TenantCreator.new(org).create_tenant
  end
end
