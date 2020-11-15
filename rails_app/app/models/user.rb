class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :webauthn_2f_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
