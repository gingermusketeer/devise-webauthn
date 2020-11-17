class AddRequiresTwoFactorAuthToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :requires_two_factor_auth, :boolean, default: false
  end
end
