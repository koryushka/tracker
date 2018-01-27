class Issue < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id,
             optional: true

  enum status:{
    pending: 0,
    progress: 1,
    resolved: 2
  }
end
