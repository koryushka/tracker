class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :issues, dependent: :destroy
  has_many :managed_issues, foreign_key: :manager_id, class_name: 'Issue'

  enum role:{
    user: 0,
    manager: 1
  }
end
