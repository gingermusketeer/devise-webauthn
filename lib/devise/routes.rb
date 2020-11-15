module ActionDispatch::Routing
  class Mapper
    protected

    def devise_webauthn2fa(mapping, controllers)
      resources :credentials, only: [:index, :new, :create, :destroy], controller: :"devise/credentials" do
        collection do
          get :check
          post :verify
        end
      end
      # resource :webauthn_2fa, :only => [:show, :update, :resend_code], :path => mapping.path_names[:two_factor_authentication], :controller => controllers[:two_factor_authentication] do
      #   collection { get "resend_code" }
      # end
    end
  end
end
