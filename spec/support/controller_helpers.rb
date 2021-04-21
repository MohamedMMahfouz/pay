# frozen_string_literal: true

module ControllerHelpers
  def sign_in_admin(admin = create(:admin))
    sign_in(admin, :admin)
  end

  def sign_in_user(user = create(:user))
    sign_in(user, :user)
  end

  def sign_in(resource, resource_type)
    if resource.nil?
      allow(request.env['warden']).to(receive(:authenticate!).and_throw(:warden, scope: resource_type))
      allow(controller).to(receive(:"current_#{resource_type}").and_return(nil))
    else
      allow(request.env['warden']).to(receive(:authenticate!).and_return(resource))
      allow(controller).to(receive(:"current_#{resource_type}").and_return(resource))
      resource
    end
  end
end
