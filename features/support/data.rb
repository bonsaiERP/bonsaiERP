module DataSupport

  def self.create_user(*args)
    args = extract_options!(args) unless args.empty?
    @user = User.create(ModelsData::user)
  end
end


module ModelsData

  def self.user
    {:first_name => "Juan", :last_name => "Perez",
    :email => "juan@example.com", "password" => "demo123",
    :password_confirmation => "demo123", :phone => "12345678"}
  end
end
