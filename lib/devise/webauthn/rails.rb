# This is needed so that the app folder is loaded for controllers etc
module Devise
  module Webauthn
    class Engine < ::Rails::Engine
      ActiveSupport.on_load(:action_controller) do
        include Devise::Webauthn::Controllers::Helpers
      end
    end
  end
end
