class Store < ApplicationRecord
  # Associations
  has_many :assignments
  has_many :employees, through: :assignments

  # Callbacks
  before_validation :reformat_phone

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true, inclusion: { in: %w[PA OH WV] }
  validates :zip, presence: true, format: { with: /\A\d{5}\z/, message: "must be a valid five digit zip code" }
  validates :phone, presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }

  # Scopes
  scope :active,       -> { where(active: true) }
  scope :inactive,     -> { where(active: false) }
  scope :alphabetical, -> { order(:name) }

  # Instance methods
  def make_active
    self.active = true
    self.save!
  end

  def make_inactive
    self.active = false
    self.save!
  end

  private

  def reformat_phone
    self.phone = phone.gsub(/[^0-9]/, "") if phone.present?
  end
end
