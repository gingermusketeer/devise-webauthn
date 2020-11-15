class InstallWebauthnForUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :webauthn_id
    end
    create_table :credentials do |t|
      t.string :external_id, index: { unique: true }, null: false
      t.string :public_key, null: false
      t.belongs_to :users, foreign_key: true, null: false
      t.string :nickname, null: false
      t.bigint :sign_count, default: 0, null: false

      t.timestamps
    end
  end
end
