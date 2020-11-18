class ApplicationController < ActionController::Base
  def requires_two_fa?(user)
    user.requires_two_factor_auth?
  end
end
