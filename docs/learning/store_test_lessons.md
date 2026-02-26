# Understanding the Store Tests

## Why Do We Write Tests at All?

Before diving into the code, it's worth asking: why bother? The short answer is **confidence**. When you write a model, you're making promises — "a store will always have a name," "phone numbers will always be 10 digits," etc. Tests are the way you *prove* those promises are kept, both right now and in the future when someone changes the code and accidentally breaks something.

A good test suite lets you change your code boldly, because if you break something, the tests will catch it immediately.

---

## The Choices We Made

### Choice 1: Minitest, not RSpec

Ruby has two popular testing frameworks: **Minitest** and **RSpec**. This project uses **Minitest** because:
- It ships with Rails by default — no extra configuration needed.
- It is simpler and more explicit. You can read a Minitest file and mostly understand it without knowing special DSL keywords.
- It's what the course (and the autograder) expects.

RSpec is also popular and you'll see it in the real world, but Minitest is a great place to start.

### Choice 2: `ActiveSupport::TestCase`, not `describe`

When Rails generates the test file, it actually starts with `describe Store do` — that's a spec-style syntax borrowed from RSpec. We replaced it with:

```ruby
class StoreTest < ActiveSupport::TestCase
```

This is the proper Minitest class-based style. It:
- Makes the test class explicit and named (`StoreTest`)
- Gives us access to all of Rails' built-in test helpers
- Works correctly with `shoulda-matchers` and `shoulda-context`

### Choice 3: Contexts, not FactoryBot

Rails also generated a file called `test/factories/stores.rb` — a FactoryBot factory for creating test data. We didn't use it. Instead, we created `test/contexts.rb`.

**Why contexts over factories?**

A **context** is a module with plain Ruby methods that create and destroy specific test data. Our `create_stores` method creates three carefully chosen stores — one active in PA, one inactive in OH, one active in WV. We *know exactly* what data exists, and we named the stores after real cities so the tests are easy to read.

Factories are more flexible (they can generate random data, vary attributes easily), but that flexibility can make tests harder to reason about. With a context, every test file that calls `create_stores` is working with the exact same three stores, every single time. That predictability is valuable.

### Choice 4: shoulda-matchers for associations

For testing associations (the `has_many` lines), we used a gem called **shoulda-matchers**:

```ruby
should have_many(:assignments)
should have_many(:employees).through(:assignments)
```

These are called **matcher macros**. They generate a complete test for you in one line. Testing associations manually would require writing SQL-level assertions or checking reflection metadata — `shoulda-matchers` handles all that complexity so you can express the test simply and readably.

### Choice 5: Explicit assertions for everything else

For validations, scopes, and methods, we wrote each test by hand rather than relying on matcher macros. This is a deliberate choice:

- It forces you to think about *what exactly* you are testing.
- It produces more readable test names (e.g., "should be invalid when zip is fewer than 5 digits").
- It makes it obvious what passes and what fails when a test breaks.

---

## The Supporting Files

Before looking at the test file itself, let's understand the two files that support it.

### `test/contexts.rb`

```ruby
module Contexts
  def create_stores
    @bethany    = Store.create!(name: "Bethany",    street: "300 College St",  city: "Bethany",    state: "WV", zip: "26032", phone: "3041234567", active: true)
    @cleveland  = Store.create!(name: "Cleveland",  street: "200 Euclid Ave",  city: "Cleveland",  state: "OH", zip: "44101", phone: "2161234567", active: false)
    @pittsburgh = Store.create!(name: "Pittsburgh", street: "100 Forbes Ave",  city: "Pittsburgh", state: "PA", zip: "15213", phone: "4121234567", active: true)
  end

  def destroy_stores
    Store.delete_all
  end
end
```

This is a Ruby **module** — a collection of methods that can be mixed into other classes. We include it in `ActiveSupport::TestCase` so every test file can use it.

`create_stores` creates three stores in the test database and stores them in **instance variables** (`@bethany`, `@cleveland`, `@pittsburgh`). The `@` prefix makes them accessible from anywhere in the current test.

Why these three stores specifically?
- **Bethany (WV, active)** — "B" comes first alphabetically, useful for ordering tests.
- **Cleveland (OH, inactive)** — gives us an inactive store in a different state.
- **Pittsburgh (PA, active)** — "P" comes last alphabetically; we use it as our "default good store" to poke and prod in validation tests.

`destroy_stores` wipes the `stores` table clean after each test group, so one test's data doesn't bleed into another.

The `!` on `Store.create!` means "raise an error if this fails." If context data can't be created, something is fundamentally broken and we want a loud, obvious failure — not a silent nil.

### `test/test_helper.rb` (the two lines we changed)

```ruby
require 'contexts'       # loads the Contexts module from test/contexts.rb
...
include Contexts         # mixes the module into every test class
```

These two lines make the `create_stores` and `destroy_stores` methods available to every test file in the project. We un-commented them because they were already there but disabled.

---

## The Test File: `test/models/store_test.rb`

Now let's walk through the entire file.

### The opening

```ruby
require "test_helper"

class StoreTest < ActiveSupport::TestCase
```

- `require "test_helper"` loads the test configuration — SimpleCov, Minitest reporters, shoulda-matchers, and our contexts. Every test file starts with this.
- `class StoreTest < ActiveSupport::TestCase` — our test class. By convention it's named after the model it tests (`Store` → `StoreTest`).

---

### Section 1: Relationships

```ruby
should have_many(:assignments)
should have_many(:employees).through(:assignments)
```

**What they test:** These two lines verify that the `Store` model has correctly declared its associations. They map directly to these lines in `store.rb`:

```ruby
has_many :assignments
has_many :employees, through: :assignments
```

**Why they are outside a context block:** These matchers don't need real data in the database. They just inspect the class's configuration. Placing them at the top level of the test class (before any `context` block) keeps them clean and separate.

**How shoulda-matchers works here:** Internally, `have_many(:assignments)` creates a new `Store` object and uses Rails' "reflection" system to check that a `has_many :assignments` association was declared on the class. If you accidentally deleted that line from `store.rb`, this test would fail immediately.

---

### The Context and Setup/Teardown

```ruby
context "Within context" do
  setup do
    create_stores
  end

  teardown do
    destroy_stores
  end
  ...
end
```

**`context`** is provided by the `shoulda-context` gem. It groups related tests together and gives them a shared label. Think of it like a folder that organizes tests.

**`setup`** runs *before each individual test* inside this context. So before every single `should` block, Rails calls `create_stores` — which puts Bethany, Cleveland, and Pittsburgh into the test database fresh.

**`teardown`** runs *after each individual test*. It calls `destroy_stores`, which wipes the table clean.

This setup/teardown cycle means every single test starts with the same clean slate. Test A cannot affect Test B because the data is rebuilt from scratch each time. This is called **test isolation** and it's one of the most important principles in testing.

---

### Section 2: Validating name

```ruby
context "Validating name" do
  should "be invalid without a name" do
    @pittsburgh.name = nil
    deny @pittsburgh.valid?
  end
```

**What it tests:** The `validates :name, presence: true` line in the model.

**How it works:** We take `@pittsburgh` (a valid store that was just created in `setup`), set its name to `nil`, and then call `.valid?`. The `.valid?` method runs all validations and returns `true` or `false`. We use `deny` (which is just `assert !condition`) to confirm the store is now *invalid*.

Notice we're not saving — we're just checking whether the object would be valid. This is intentional: we want to test the validation rule itself, not the database.

```ruby
  should "be invalid with a duplicate name (same case)" do
    dupe = Store.new(name: "Pittsburgh", ...)
    deny dupe.valid?
  end

  should "be invalid with a duplicate name (different case)" do
    dupe = Store.new(name: "pittsburgh", ...)
    deny dupe.valid?
  end
```

**What they test:** The `uniqueness: { case_sensitive: false }` part of the name validation.

**Why two tests?** The spec says names must be unique *case-insensitively*. So we test both the obvious case (exact match "Pittsburgh") and the tricky case (lowercase "pittsburgh"). The model uses `case_sensitive: false`, which means it queries the database in a way that ignores case. Two tests make it clear that both scenarios are handled.

**Why do we need `@pittsburgh` to exist?** Uniqueness validation works by checking the database for an existing record with the same value. If no stores existed, `dupe` wouldn't find any conflict and would appear valid. The `setup` block is what puts Pittsburgh in the database so the conflict is detectable.

```ruby
  should "be valid with a unique name" do
    new_store = Store.new(name: "Weirton", ...)
    assert new_store.valid?
  end
```

**What it tests:** The positive case — that a store with a brand new name IS valid. This might seem obvious, but it's good practice to always test the "happy path" alongside the failure cases. It confirms your validation isn't accidentally blocking everything.

---

### Section 3: Validating street and city

```ruby
context "Validating street" do
  should "be invalid without a street" do
    @pittsburgh.street = nil
    deny @pittsburgh.valid?
  end
end

context "Validating city" do
  should "be invalid without a city" do
    @pittsburgh.city = nil
    deny @pittsburgh.valid?
  end
end
```

**What they test:** `validates :street, presence: true` and `validates :city, presence: true`.

**Why only one test each?** These are simple presence validations with no other rules. One test proving they fail when nil is sufficient. There's nothing more complex to check.

---

### Section 4: Validating state

```ruby
context "Validating state" do
  should "be invalid without a state" do ...
  should "accept PA as a valid state" do ...
  should "accept OH as a valid state" do ...
  should "accept WV as a valid state" do ...
  should "reject a state outside PA, OH, and WV" do ...
end
```

**What they test:** `validates :state, presence: true, inclusion: { in: %w[PA OH WV] }`.

**Why five tests?** The state validation has two distinct rules:
1. It must be present (one test).
2. It must be one of exactly three values (four tests: one for each valid value, one for a clearly invalid value).

Testing each valid value individually (PA, OH, WV) might feel like overkill, but it's the right call here. If someone accidentally changed the model to `%w[PA OH]` and forgot WV, only a test that specifically uses "WV" would catch it. Similarly, the rejection test uses "NY" — a real US state, but not one Classic Creamery operates in — to confirm the boundary is enforced.

---

### Section 5: Validating zip

```ruby
context "Validating zip" do
  should "be invalid without a zip" do ...           # nil
  should "be invalid when zip is fewer than 5 digits" do ...  # "1234"
  should "be invalid when zip is more than 5 digits" do ...   # "123456"
  should "be invalid when zip contains non-digit characters" do ...  # "1234a"
  should "be valid with a proper 5-digit zip" do ...  # "15217"
end
```

**What they test:** `validates :zip, format: { with: /\A\d{5}\z/ }`.

**Why five tests?** The regex `/\A\d{5}\z/` has several boundaries we need to probe:
- Too short (4 digits) → should fail
- Too long (6 digits) → should fail
- Right length but wrong characters (a letter) → should fail
- Nil → should fail (presence check)
- Exactly right → should pass

Each test pokes at a different edge of the regex. This is called **boundary testing** — you test values just inside and just outside the valid range, because those are the places where bugs hide.

---

### Section 6: Validating phone

```ruby
context "Validating phone" do
  should "be invalid without a phone" do ...
  should "be invalid when fewer than 10 digits are given" do ...
  should "be invalid when more than 10 digits are given" do ...
  should "accept a plain 10-digit phone number" do ...
  should "accept phone with dashes and normalize to 10 digits" do ...
  should "accept phone with dots and normalize to 10 digits" do ...
  should "accept phone with parentheses and spaces and normalize to 10 digits" do ...
end
```

**What they test:** Both the `validates :phone` validation *and* the `before_validation :reformat_phone` callback together.

These tests are the most interesting because they test two features interacting. The callback runs first and strips the phone to digits, then the validation checks the result. So by testing formatted input and confirming the stored value is clean digits, we're verifying that the whole pipeline works end to end.

Look at one of the format tests closely:

```ruby
should "accept phone with dashes and normalize to 10 digits" do
  store = Store.new(name: "Weirton", street: "1 Main St", city: "Weirton",
                    state: "WV", zip: "26062", phone: "304-123-4567")
  assert store.valid?
  assert_equal "3041234567", store.phone
end
```

There are **two assertions** here:
1. `assert store.valid?` — The store passes validation (meaning the callback successfully cleaned the phone and the validation accepted the result).
2. `assert_equal "3041234567", store.phone` — The phone attribute is now the clean 10-digit string, not the original dashed version.

We also create a brand new `Store.new(...)` rather than modifying `@pittsburgh`. That's because we need a store with a unique name (name uniqueness!), and Weirton doesn't exist in our context data.

**Why three format tests (dashes, dots, parentheses)?** The spec says those are all acceptable formats. Testing each one proves the `gsub(/[^0-9]/, "")` regex works for all the common separators users might type.

---

### Section 7: Scopes

```ruby
context "For scopes" do
  should "return only active stores with the active scope" do
    active = Store.active.to_a
    assert_includes active, @pittsburgh
    assert_includes active, @bethany
    deny active.include?(@cleveland)
  end
```

**What it tests:** `scope :active, -> { where(active: true) }`.

**Pattern:** For scope tests, we always check:
1. Things that *should* be in the result — using `assert_includes`
2. Things that *should NOT* be in the result — using `deny ... .include?`

Checking both sides is important. A scope that returns *everything* would pass a test that only checks for inclusions. By also checking that inactive stores are excluded, we confirm the filter is actually working.

`.to_a` converts the ActiveRecord result into a plain Ruby array, which makes the assertions simpler to work with.

```ruby
  should "return all stores in alphabetical order by name" do
    assert_equal [@bethany, @cleveland, @pittsburgh], Store.alphabetical.to_a
  end
```

**What it tests:** `scope :alphabetical, -> { order(:name) }`.

This is why we chose the names Bethany, Cleveland, and Pittsburgh — their alphabetical order (B < C < P) is unambiguous. `assert_equal` checks both the contents *and* the order of the array. A scope that returned all stores in reverse order would fail this test even though the right stores are present.

---

### Section 8: Methods

```ruby
context "For make_active" do
  should "set active to true and persist the change" do
    @cleveland.make_active
    assert @cleveland.active
    assert Store.find(@cleveland.id).active
  end
end
```

**What it tests:** The `make_active` method, which sets `active = true` and calls `save!`.

**Why two assertions?** This is the key insight for testing any method that saves to the database:
1. `assert @cleveland.active` — Checks the *in-memory object*. Did the attribute change?
2. `assert Store.find(@cleveland.id).active` — Loads a *fresh copy from the database*. Did it actually get saved?

If `make_active` set the attribute but forgot to call `save!`, the first assertion would pass but the second would fail. This two-part pattern is the correct way to test any method that claims to persist data.

We use `@cleveland` here because Cleveland was created as *inactive* in the context — so calling `make_active` on it represents a real state change.

```ruby
context "For make_inactive" do
  should "set active to false and persist the change" do
    @pittsburgh.make_inactive
    deny @pittsburgh.active
    deny Store.find(@pittsburgh.id).active
  end
end
```

**What it tests:** The `make_inactive` method, the mirror of `make_active`.

Same two-assertion pattern, but using `deny` since we're checking for `false`. We use `@pittsburgh` here because it was created as *active* — flipping it to inactive is the meaningful change to test.

---

## How SimpleCov Knows We Have 100% Coverage

SimpleCov tracks which **lines** of source code are actually executed during your tests. After all 30 tests run, it reports:

```
Line Coverage: 100.0% (28 / 28)
```

Here's how each line of `store.rb` gets covered:

| Lines in `store.rb` | Covered by |
|---|---|
| `has_many :assignments` | Covered when the class loads (just declaring it executes the line) |
| `has_many :employees, through: :assignments` | Same |
| `before_validation :reformat_phone` | Same |
| All `validates` lines | Same |
| All `scope` lines | Same |
| `self.active = true` and `self.save!` in `make_active` | The `make_active` test |
| `self.active = false` and `self.save!` in `make_inactive` | The `make_inactive` test |
| `self.phone = phone.gsub(...)` in `reformat_phone` | Any test that calls `.valid?` on a store with a phone value |

The class-level declarations (`has_many`, `validates`, `scope`) are executed the moment Ruby loads the file — just requiring `store.rb` covers those lines. The method *bodies* need to actually be called to be covered, which is why we need explicit tests for `make_active`, `make_inactive`, and `reformat_phone`.

---

## Key Testing Vocabulary Recap

| Term | What it means |
|---|---|
| **`assert`** | Passes if the condition is true; fails otherwise |
| **`deny`** | Passes if the condition is false (the opposite of assert) |
| **`assert_equal expected, actual`** | Passes if the two values are equal |
| **`assert_includes collection, item`** | Passes if the item is in the collection |
| **`should`** | A shoulda-context method that creates a named test |
| **`context`** | A shoulda-context block that groups related tests |
| **`setup`** | Runs before each test in its context |
| **`teardown`** | Runs after each test in its context |
| **`.valid?`** | Runs all validations on an object; returns true or false |
| **`Store.new`** | Creates an unsaved store object in memory |
| **`Store.create!`** | Creates and immediately saves a store to the database |
| **Test isolation** | The principle that each test starts fresh and can't affect others |
| **Boundary testing** | Testing values at the edges of what's valid/invalid |
| **Happy path** | A test that verifies the correct behavior works (not just failures) |
