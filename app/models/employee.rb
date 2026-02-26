class Employee < ApplicationRecord
  # Associations
  has_many :assignments
  has_many :stores, through: :assignments

  # Enums
  enum :role, { employee: 1, manager: 2, admin: 3 }, suffix: true, default: "employee"

  # Callbacks
  before_validation :reformat_phone
  before_validation :reformat_ssn

  # Validations
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :phone, presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }
  validates :ssn, presence: true, uniqueness: true, format: { with: /\A\d{9}\z/, message: "must be a 9-digit number" }

  # Scopes
  scope :active,       -> { where(active: true) }
  scope :inactive,     -> { where(active: false) }
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :regulars,     -> { where(role: 1) }
  scope :managers,     -> { where(role: 2) }
  scope :admins,       -> { where(role: 3) }
  scope :unassigned,   -> { where.not(id: Assignment.where(end_date: nil).select(:employee_id)) }

  # Instance methods
  def name
    "#{last_name}, #{first_name}"
  end

  # def proper_name
  #   "#{first_name} #{last_name}"
  # end

  def over_18?
    date_of_birth <= 18.years.ago.to_date
  end

  def current_assignment
    assignments.where(end_date: nil).first
  end

  # def make_active
  #   self.active = true
  #   self.save!
  # end

  # def make_inactive
  #   self.active = false
  #   self.save!
  # end

  private

  def reformat_phone
    self.phone = phone.gsub(/[^0-9]/, "") if phone.present?
  end

  def reformat_ssn
    self.ssn = ssn.gsub(/[^0-9]/, "") if ssn.present?
  end
end
