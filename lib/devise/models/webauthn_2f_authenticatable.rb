module Devise
  module Models
    module Webauthn2fAuthenticatable
      extend ActiveSupport::Concern

      included do
        has_many :credentials, class_name: "::Devise::Webauthn::Credential"

        after_initialize do
          self.webauthn_id ||= ::WebAuthn.generate_user_id
        end
      end
    end
  end
end
