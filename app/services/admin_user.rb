# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to add or update users by the admin
class AdminUser < BaseForm
  attribute :email, String
  attribute :first_name, String
  attribute :last_name, String
  attribute :role, String
  attribute :organisation, Organisation

  validates :email, email_format: true, presence: true
  validates :organisation, presence: true
  validates :role, presence: true, inclusion: { in: User::ROLES.slice(1, 2) }

  delegate :id, to: :user, prefix: true

  def create
    return false  unless valid?
    commit_or_rollback do
      res = user.save && link.save
      send_email  if res

      res
    end
  end

  def update(attributes)
    self.attributes = attributes

    return false unless  valid?
    set_user_attributes
    link.role = role

    commit_or_rollback do
      user.save && link.save
    end
  end

  def valid?
    res = super && user.valid?
    set_user_errors

    res
  end

  def user
    @user ||= User.new(
      email: email, password: random_password,
      first_name: first_name, last_name: last_name
    )
  end

  def link
    @link ||= organisation.links.build(
      user_id: user.id, role: role, api_token: api_token
    )
  end

  def self.find(organisation, user_id)
    user = organisation.users.find(user_id)
    _object = new(slice_user_attributes(user))
    _object.organisation = organisation
    _object.set_user(user)
    link = user.links.where(organisation_id: organisation.id).first!

    _object.set_link(link)
    _object.role = link.role
    _object
  end

  def set_user(user)
    @user = user
  end

  def set_link(link)
    @link = link
  end

  private

    def send_email
      RegistrationMailer.user_registration(self).deliver_now!
    end

    def self.slice_user_attributes(user)
      user.attributes.slice(
        'email', 'first_name', 'last_name',
        'phone', 'mobile')
    end

    def set_user_errors
      return  if  user.errors.messages.blank?
      user.errors.messages[:email].each do |msg|
        errors.add(:email, msg)
      end
    end

    # Generates a random password and sets it to the password field
    def random_password(size = 8)
      SecureRandom.urlsafe_base64(size)
    end

    def set_user_attributes
      user.attributes = attributes.except(:role, :organisation)
    end

    def api_token
      SecureRandom.urlsafe_base64(32)
    end
end
