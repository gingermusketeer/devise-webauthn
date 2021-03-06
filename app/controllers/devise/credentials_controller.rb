class Devise::CredentialsController < DeviseController
  prepend_before_action :authenticate_scope!
  before_action :ensure_resource_present
  # skip_before_action :verify_2fa!, only: [:check, :verify]

  def index
    @credentials = resource.credentials
  end

  def new
    @credential = resource.credentials.new

    @create_options = WebAuthn::Credential.options_for_create(
      user: {
        id: resource.webauthn_id,
        name: resource.email,
      },
      # This prevents the credential being registered again
      # exclude: resource.credentials.pluck(:external_id),
    )
    @challenge = @create_options.challenge
    session[:current_registration] = { challenge: @challenge }
  end

  def create
    webauthn_credential = WebAuthn::Credential.from_create(params)
    challenge = session["current_registration"]["challenge"]

    webauthn_credential.verify(challenge)

    @credential = resource.credentials.find_or_initialize_by(
      external_id: Base64.strict_encode64(webauthn_credential.raw_id),
    )

    if @credential.update(
      nickname: params[:credential_nickname],
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count,
    )
      redirect_to root_url
    else
      puts "failed"
      puts @credential.errors.full_messages
      render :new
    end
  rescue WebAuthn::Error => e
    puts e
    # render json: "Verification failed: #{e.message}", status: :unprocessable_entity
    render :new
  ensure
    session.delete("current_registration")
  end

  def destroy
    resource.credentials.destroy(params[:id])
    redirect_to root_path
  end

  def check
    ids = resource.credentials.pluck(:external_id)
    @check_options = WebAuthn::Credential.options_for_get(allow: ids)

    # Store the newly generated challenge somewhere so you can have it
    # for the verification phase.
    session[:authentication_challenge] = @check_options.challenge
  end

  def verify
    webauthn_credential = WebAuthn::Credential.from_get(params)

    # stored_credential = scope.find_by(external_id: webauthn_credential.id)
    stored_credential = resource.credentials.find_by(external_id: Base64.strict_encode64(webauthn_credential.raw_id))
    # stored_credential = scope.find_by(external_id: Base64.strict_encode64(webauthn_credential.raw_id))

    begin
      webauthn_credential.verify(
        session[:authentication_challenge],
        public_key: stored_credential.public_key,
        sign_count: stored_credential.sign_count,
      )

      # Update the stored credential sign count with the value from `webauthn_credential.sign_count`
      stored_credential.update!(sign_count: webauthn_credential.sign_count)

      # Continue with successful sign in or 2FA verification...
      mark_2fa_checked(resource_name)
      redirect_to root_url
    rescue WebAuthn::SignCountVerificationError => e
      # Cryptographic verification of the authenticator data succeeded, but the signature counter was less then or equal
      # to the stored value. This can have several reasons and depending on your risk tolerance you can choose to fail or
      # pass authentication. For more information see https://www.w3.org/TR/webauthn/#sign-counter
    rescue WebAuthn::Error => e
      # Handle error
    end
  end

  private

  def authenticate_scope!
    self.resource = send("current_#{resource_name}")
  end

  def ensure_resource_present
    redirect_to :root if resource.nil?
  end
end
