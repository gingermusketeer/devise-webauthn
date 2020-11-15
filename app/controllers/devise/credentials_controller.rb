class Devise::CredentialsController < DeviseController
  # skip_before_action :verify_2fa!, only: [:check, :verify]

  def index
    @credentials = current_user.credentials
  end

  def new
    @credential = current_user.credentials.new
    authorize(@credential)

    @create_options = WebAuthn::Credential.options_for_create(
      user: {
        id: current_user.webauthn_id,
        name: current_user.name,
      },
      # This prevents the credential being registered again
      # exclude: current_user.credentials.pluck(:external_id),
    )
    @challenge = @create_options.challenge
    session[:current_registration] = { challenge: @challenge }
  end

  def create
    policy_scope(Credential)
    webauthn_credential = WebAuthn::Credential.from_create(params)
    challenge = session["current_registration"]["challenge"]

    webauthn_credential.verify(challenge)

    @credential = current_user.credentials.find_or_initialize_by(
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
    policy_scope(Credential)
    current_user.credentials.destroy(params[:id])
    redirect_to root_path
  end

  def check
    scope = policy_scope(Credential)
    authorize(scope)

    ids = scope.limit(1).pluck(:external_id)
    @check_options = WebAuthn::Credential.options_for_get(allow: ids)

    # Store the newly generated challenge somewhere so you can have it
    # for the verification phase.
    session[:authentication_challenge] = @check_options.challenge
  end

  def verify
    scope = policy_scope(Credential)
    authorize(scope)
    webauthn_credential = WebAuthn::Credential.from_get(params)

    # stored_credential = scope.find_by(external_id: webauthn_credential.id)
    stored_credential = scope.find_by(external_id: Base64.strict_encode64(webauthn_credential.raw_id))
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
      session[:two_factor_checked_at] = Time.current
      redirect_to root_url
    rescue WebAuthn::SignCountVerificationError => e
      # Cryptographic verification of the authenticator data succeeded, but the signature counter was less then or equal
      # to the stored value. This can have several reasons and depending on your risk tolerance you can choose to fail or
      # pass authentication. For more information see https://www.w3.org/TR/webauthn/#sign-counter
    rescue WebAuthn::Error => e
      # Handle error
    end
  end
end
