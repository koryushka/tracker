class Issue < ApplicationRecord
  self.per_page = 25

  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id,
             optional: true

  validates :title, presence: true
  validates :content, presence: true
  validates :manager_id,
            presence: { message: I18n.t('errors.validation.manager')},
            if: ->(obj){ obj.resolved? || obj.progress? }

  enum status:{
    pending: 0,
    progress: 1,
    resolved: 2
  }

  def change_status(status:)
    unless valid_status?(status: status)
      errors.add(:status, 'Invalid status')
      return
    end
    send("#{status}!")
  end

  private

  def valid_status?(status:)
    self.class.statuses.keys.include?(status)
  end
end
