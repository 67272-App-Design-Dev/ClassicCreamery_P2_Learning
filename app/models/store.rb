class Store < ApplicationRecord
  # -- Associations --
  # A store can have many assignments (one per employee per time period).
  # Through those assignments, we can also reach all the employees who
  # have ever worked at this store. Rails handles the JOIN query automatically.
  has_many :assignments
  has_many :employees, through: :assignments

  # -- Callbacks --
  # before_validation means: run reformat_phone BEFORE Rails checks the
  # validations below. This way, a user can type "412-555-1234" and it
  # gets cleaned up to "4125551234" before we check if it's 10 digits.
  # If we used before_save instead, the format check would run first and
  # reject valid numbers that just have dashes or dots in them.
  before_validation :reformat_phone

  # -- Validations --
  # Each line is a rule that must pass before a store can be saved.
  # If any rule fails, the record is NOT saved and errors are stored on the object.

  # Name must exist and no two stores can share the same name.
  # case_sensitive: false means "Pittsburgh" and "pittsburgh" count as the same.
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Street and city just need to be present -- no special format required.
  validates :street, presence: true
  validates :city,   presence: true

  # State must be present AND must be one of these three values.
  # %w[PA OH WV] is Ruby shorthand for the array ["PA", "OH", "WV"].
  validates :state, presence: true, inclusion: { in: %w[PA OH WV] }

  # Zip must be present AND match the regex /\A\d{5}\z/.
  # Regex breakdown: \A = start of string, \d = any digit, {5} = exactly 5 of them, \z = end of string.
  # So the entire string must be exactly 5 digits and nothing else.
  validates :zip, presence: true, format: { with: /\A\d{5}\z/, message: "must be a valid five digit zip code" }

  # Phone must be present AND match exactly 10 digits.
  # By the time this runs, reformat_phone has already stripped out dashes,
  # dots, parentheses, etc. -- so this check just counts the digits.
  validates :phone, presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }

  # -- Scopes --
  # Scopes are reusable, named database queries. The -> { } syntax is a lambda
  # (a small anonymous function) that runs the query when the scope is called.
  # Scopes are also chainable: Store.active.alphabetical works in one SQL query.

  scope :active,       -> { where(active: true) }   # only open stores
  scope :inactive,     -> { where(active: false) }  # only closed stores
  scope :alphabetical, -> { order(:name) }          # sort A to Z by name

  # -- Instance Methods --
  # These methods run on a single store object (e.g., my_store.make_active).
  # "self" refers to the specific store the method is being called on.

  # Flips this store to active and immediately saves the change to the database.
  # save! (with a bang) raises an error if saving fails, rather than returning false silently.
  def make_active
    self.active = true
    self.save!
  end

  # Flips this store to inactive and immediately saves the change to the database.
  def make_inactive
    self.active = false
    self.save!
  end

  # -- Private Methods --
  # "private" means these methods can only be called from inside this class.
  # They are internal helpers, not part of the public interface.
  private

  # Strips everything that is not a digit from the phone number.
  # gsub (global substitution) replaces every match of the pattern with the second argument.
  # /[^0-9]/ matches any character that is NOT a digit (^ inside [] means "not").
  # Replacing those characters with "" (empty string) effectively deletes them.
  # Examples: "412-555-1234" -> "4125551234"   |   "(412) 555.1234" -> "4125551234"
  # The "if phone.present?" guard prevents a crash if phone is nil or blank.
  def reformat_phone
    self.phone = phone.gsub(/[^0-9]/, "") if phone.present?
  end
end
