class ApplicationController < ActionController::Base
  def requires_two_fa?(user)
    true
  end
end
