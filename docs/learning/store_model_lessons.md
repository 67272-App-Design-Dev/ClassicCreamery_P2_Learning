# Understanding the Store Model

## What is a Model?

In a Rails application, a **model** is a Ruby class that represents one type of thing your app cares about — and it connects directly to a table in your database. Every row in the `stores` table in the database becomes a `Store` object in Ruby that you can work with in your code.

Think of it like this: the database table is a spreadsheet, and each row is one store location. The model is the code that lets you read, create, update, and delete those rows — and also enforces rules about what data is allowed.

---

## The File: `app/models/store.rb`

Here is the full model we wrote, broken down piece by piece:

```ruby
class Store < ApplicationRecord
```

This line says: "Create a class called `Store` that inherits from `ApplicationRecord`." The `< ApplicationRecord` part is what gives `Store` all of its database superpowers — things like `.find`, `.create`, `.save`, `.where`, and much more. Rails provides all of that for free just by inheriting from `ApplicationRecord`.

---

## Part 1: Associations

```ruby
has_many :assignments
has_many :employees, through: :assignments
```

These two lines describe **relationships** between models — how a `Store` is connected to other things in the system.

- `has_many :assignments` means: "A store can have many assignments." In database terms, there are rows in the `assignments` table that each have a `store_id` pointing back to this store.
- `has_many :employees, through: :assignments` means: "A store has many employees, but we get to them *through* the assignments table." The `assignments` table acts as a bridge — an employee is connected to a store because there's an assignment linking them.

This is called a **many-to-many relationship**: a store can have many employees, and an employee can work at many stores over time. The `assignments` table sits in the middle and connects them.

Once you write these two lines, Rails gives you free helper methods. For example, if you have a store object, you can just write `store.employees` and Rails will figure out the SQL query automatically.

---

## Part 2: Callbacks

```ruby
before_validation :reformat_phone
```

A **callback** is a method that Rails calls automatically at a specific moment in an object's life. This one says: "Before you check whether this store is valid, first run the `reformat_phone` method."

This matters because users might type a phone number in many different formats:
- `412-123-4567`
- `412.123.4567`
- `(412) 123-4567`

We want to store it consistently as just 10 digits — `4121234567` — no matter what the user types. The callback runs `reformat_phone` first to clean up the number, and *then* our validation checks whether the result is exactly 10 digits. You'll see how `reformat_phone` works at the bottom of the file.

The reason we use `before_validation` instead of `before_save` is timing. In Rails, the order of events when you save a record is:

1. `before_validation` runs
2. Validations run
3. `before_save` runs
4. The record is saved to the database

We need the phone to be cleaned up *before* validation, otherwise the validation would see `412-123-4567` (12 characters) and reject it, even though it's a valid number.

---

## Part 3: Validations

```ruby
validates :name,  presence: true, uniqueness: { case_sensitive: false }
validates :street, presence: true
validates :city,   presence: true
validates :state,  presence: true, inclusion: { in: %w[PA OH WV] }
validates :zip,    presence: true, format: { with: /\A\d{5}\z/, message: "must be a valid five digit zip code" }
validates :phone,  presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }
```

**Validations** are rules that protect your database from bad data. Every time you try to save a `Store`, Rails checks all these rules first. If any of them fail, the record is NOT saved and the errors are stored on the object so you can tell the user what went wrong.

Let's go through each one:

### `validates :name, presence: true, uniqueness: { case_sensitive: false }`
- `presence: true` — The name can't be blank. A store must have a name.
- `uniqueness: { case_sensitive: false }` — No two stores can have the same name, even if one is `"Pittsburgh"` and one is `"pittsburgh"`. The `case_sensitive: false` makes the comparison ignore uppercase vs lowercase.

### `validates :street, presence: true` and `validates :city, presence: true`
Simple — these fields can't be blank. Nothing fancy needed.

### `validates :state, presence: true, inclusion: { in: %w[PA OH WV] }`
- `presence: true` — State can't be blank.
- `inclusion: { in: %w[PA OH WV] }` — The state must be one of those three values. `%w[PA OH WV]` is just a Ruby shorthand for the array `["PA", "OH", "WV"]`. Right now Classic Creamery only operates in Pennsylvania, Ohio, and West Virginia.

### `validates :zip, presence: true, format: { with: /\A\d{5}\z/, ... }`
- `presence: true` — Zip can't be blank.
- `format: { with: /\A\d{5}\z/ }` — This uses a **regular expression** (regex) to enforce the format. Let's break down the regex `/\A\d{5}\z/`:
  - `\A` means "start of the string"
  - `\d` means "any digit (0-9)"
  - `{5}` means "exactly 5 of the previous thing"
  - `\z` means "end of the string"
  - Together: "The entire string must be exactly 5 digits and nothing else."

### `validates :phone, presence: true, format: { with: /\A\d{10}\z/, ... }`
Same idea as zip, but requiring exactly 10 digits. Remember: by the time this validation runs, the `before_validation` callback has already stripped the phone down to only digits, so `"412-123-4567"` has already become `"4121234567"` and passes just fine.

---

## Part 4: Scopes

```ruby
scope :active,       -> { where(active: true) }
scope :inactive,     -> { where(active: false) }
scope :alphabetical, -> { order(:name) }
```

A **scope** is a reusable database query that you give a name to. Each one is essentially a shortcut for a SQL query.

The `-> { ... }` syntax is a Ruby **lambda** — think of it as a small, anonymous function that gets called when you use the scope.

- `Store.active` → runs `WHERE active = true` in the database. Returns only open stores.
- `Store.inactive` → runs `WHERE active = false`. Returns only closed stores.
- `Store.alphabetical` → runs `ORDER BY name`. Returns all stores sorted A to Z.

Scopes are also **chainable**, which is powerful. For example:
```ruby
Store.active.alphabetical
```
This returns only active stores, sorted alphabetically — Rails combines both conditions into a single efficient SQL query.

---

## Part 5: Instance Methods

```ruby
def make_active
  self.active = true
  self.save!
end

def make_inactive
  self.active = false
  self.save!
end
```

An **instance method** is a method that runs on one specific store object (as opposed to a scope, which runs on the whole table).

- `self` refers to the specific store object you're calling the method on. So `self.active = true` sets the `active` attribute on *this* store to `true`.
- `self.save!` saves that change to the database immediately. The `!` (bang) version of save will raise an error if saving fails, rather than silently returning `false`.

Usage example:
```ruby
store = Store.find(1)   # find the store with id = 1
store.make_inactive     # set active = false and save it
```

---

## Part 6: The Private Callback Method

```ruby
private

def reformat_phone
  self.phone = phone.gsub(/[^0-9]/, "") if phone.present?
end
```

The `private` keyword means this method can only be called from *inside* the class — it's a helper method for internal use, not something outside code should call directly.

`reformat_phone` is the method our `before_validation` callback points to. Here's what it does:

- `if phone.present?` — Only do anything if the phone field isn't nil or blank.
- `phone.gsub(/[^0-9]/, "")` — `gsub` stands for "global substitution." The regex `/[^0-9]/` matches any character that is NOT a digit (the `^` inside `[]` means "not"). The second argument `""` is what to replace it with — an empty string, meaning we just delete all non-digit characters.
- `self.phone = ...` — Assign the cleaned-up string back to the phone field.

So `"(412) 123-4567"` becomes `"4121234567"`, and `"412.123.4567"` also becomes `"4121234567"`.

---

## Putting It All Together

Here's the flow of what happens when someone tries to create a new store:

```
Store.create(name: "Weirton", state: "WV", zip: "26062", phone: "(304) 555-1234", ...)
        │
        ▼
  before_validation runs
  → reformat_phone strips phone to "3045551234"
        │
        ▼
  Validations run
  → Is name present? ✓
  → Is name unique? ✓
  → Is state in [PA, OH, WV]? ✓
  → Does zip match 5 digits? ✓
  → Does phone match 10 digits? ✓  (it does now, after reformatting)
        │
        ▼
  All validations passed → record is saved to the database ✓
```

If any validation had failed, the record would NOT have been saved, and `store.errors` would contain a description of what went wrong.

---

## Key Vocabulary Recap

| Term | What it means |
|---|---|
| **Model** | A Ruby class that maps to a database table |
| **Association** | A relationship between two models (has_many, belongs_to, etc.) |
| **Callback** | A method Rails calls automatically at a specific moment (before_validation, before_save, etc.) |
| **Validation** | A rule that must pass before a record can be saved |
| **Scope** | A named, reusable database query |
| **Instance method** | A method that runs on one specific object |
| **Regex** | A pattern for matching text, written between `/` slashes |
| **`self`** | Refers to the current object the method is being called on |
| **`private`** | Makes a method only accessible from within the class itself |
