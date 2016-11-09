module RegistrationHelper
  def log_in(email, password, options={})
    sign_up(email, password, options)
    sign_in(email, password)
  end

  def sign_up(email, password, options={})
    user_name = email.split("@").first
    @user = User.find_by_email(email) || create_user(:email => email, :password => password, :name => user_name)
    if options[:group].present?
      @group = Group.find_by_name(options[:group]) || FactoryGirl.create(:group, :name => options[:group])
      if options[:level].present?
        @membership = Membership.create!(:member => @user, :group => @group, :level => options[:level])
      end
    end
  end

  def sign_in(email, password)
    visit path_to("the home page")
    click_link "sign_in"
    fill_in "Email",    :with => email
    fill_in "Password", :with => password
    click_button("sign_in")
  end
end

World(RegistrationHelper)