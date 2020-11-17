require "webauthn"
require "devise/webauthn/railtie"
require "devise/webauthn/rails"
require "devise/models/webauthn_2f_authenticatable"
require "devise/routes"

module Devise
  module Webauthn
    COOKIE_NAME = "devise_webauthn"

    module Controllers
      autoload :Helpers, "devise/webauthn/controllers/helpers"
    end
  end
end

Devise.add_module :webauthn_2f_authenticatable,
  # model: "devise/models/webauthn_2fa_authenticatable",
  controller: :"devise/webauthn/credentials",
  route: :webauthn2fa

WebAuthn.configure do |config|
  # This value needs to match `window.location.origin` evaluated by
  # the User Agent during registration and authentication ceremonies.
  config.origin = "http://localhost:4000"

  # Relying Party name for display purposes
  config.rp_name = "Test"

  # Optionally configure a client timeout hint, in milliseconds.
  # This hint specifies how long the browser should wait for any
  # interaction with the user.
  # This hint may be overridden by the browser.
  # https://www.w3.org/TR/webauthn/#dom-publickeycredentialcreationoptions-timeout
  # config.credential_options_timeout = 120_000

  # You can optionally specify a different Relying Party ID
  # (https://www.w3.org/TR/webauthn/#relying-party-identifier)
  # if it differs from the default one.
  #
  # In this case the default would be "auth.example.com", but you can set it to
  # the suffix "example.com"
  #
  # config.rp_id = "example.com"

  # Configure preferred binary-to-text encoding scheme. This should match the encoding scheme
  # used in your client-side (user agent) code before sending the credential to the server.
  # Supported values: `:base64url` (default), `:base64` or `false` to disable all encoding.
  #
  # config.encoding = :base64url

  # Possible values: "ES256", "ES384", "ES512", "PS256", "PS384", "PS512", "RS256", "RS384", "RS512", "RS1"
  # Default: ["ES256", "PS256", "RS256"]
  #
  # config.algorithms << "ES384"
end
