# Forces that all rake tasks are runned in test

namespace :bonsai_test do
  def check_is_test
    raise 'Error you must run with RAILS_ENV=test'  unless Rails.env.test?
  end

  desc 'Creates organisation and tenant'
  task create_tenant: :environment do
    check_is_test
    Rake::Task['bonsai_test:delete_organisations'].invoke

    r = Registration.new({name: 'bonsai', email: 'boris@bonsaierp.com',
     password: 'demo1234'})

    r.register
    u = r.user
    UserSession.user = u
    u.confirm_registration

    org = r.organisation
    org.update(country_code: 'BO', currency: 'BOB')

    TenantCreator.new(org).create_tenant
    puts "Tenant #{org.tenant} has been created"
  end

  desc 'Eliminates all organisations'
  task delete_organisations: :environment do
    check_is_test
    Organisation.all.each { |org| org.drop_related! }
  end

  desc 'List organisations'
  task list_organisations: :environment do
    check_is_test
    puts Organisation.all.map(&:name)
  end
end
