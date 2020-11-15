module Devise
  module Webauthn
    class Credential < ::ApplicationRecord
      self.table_name = :credentials
    end
  end
end
