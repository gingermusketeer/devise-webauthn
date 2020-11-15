require "webauthn"
require "devise/webauthn/railtie"
require "devise/webauthn/rails"
require "devise/models/webauthn_2f_authenticatable"
require "devise/routes"

module Devise
  module Webauthn
    # Your code goes here...
  end
end

Devise.add_module :webauthn_2f_authenticatable,
  # model: "devise/models/webauthn_2fa_authenticatable",
  controller: :"devise/webauthn/credentials",
  route: :webauthn2fa
