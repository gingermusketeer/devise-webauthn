module Devise
  module Webauthn
    module Controllers
      module Helpers
        extend ActiveSupport::Concern

        included do
          before_action :check_2fa_status
        end

        private

        def check_2fa_status
          return if devise_controller?
          Devise.mappings.keys.flatten.any? do |scope|
            next unless signed_in?(scope)
            current_resource = send(:"current_#{scope}")
            next unless requires_two_fa?(current_resource)
            if signed_in?(scope) && !two_factor_valid?(warden.session(scope)[Devise::Webauthn::COOKIE_NAME])
              handle_failed_second_factor(scope)
            end
          end
        end

        def mark_2fa_checked(scope)
          warden.session(scope)[Devise::Webauthn::COOKIE_NAME] = Time.current
        end

        def two_factor_valid?(last_checked_at)
          return false if last_checked_at.nil?
          Time.parse(last_checked_at) > two_factor_age_limit
        end

        def two_factor_age_limit
          1.hour.ago
        end

        def handle_failed_second_factor(scope)
          if request.format.present?
            if request.format.html?
              session["#{scope}_return_to"] = request.original_fullpath if request.get?
              redirect_to check_credentials_path_for(scope)
            elsif request.format.json?
              session["#{scope}_return_to"] = root_path(format: :html)
              render json: { redirect_to: check_credentials_path_for(scope) }, status: :unauthorized
            end
          else
            head :unauthorized
          end
        end

        def check_credentials_path_for(resource_or_scope = nil)
          scope = Devise::Mapping.find_scope!(resource_or_scope)
          check_path = "check_#{scope}_credentials_path"
          send(check_path)
        end
      end
    end
  end
end
