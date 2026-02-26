# Understanding the Employee Tests

---

## Lines 4–6: `validate_presence_of` matchers

```ruby
should validate_presence_of(:first_name)
should validate_presence_of(:last_name)
should validate_presence_of(:ssn)
```

These three lines are the simplest tests in the file. They say: if I try to save an employee without a first name, last name, or SSN, it should be rejected. The model code that satisfies them is completely straightforward:

```ruby
validates :first_name, presence: true
validates :last_name,  presence: true
validates :ssn, presence: true, ...
```

Nothing tricky here. The only interesting question was: why isn't `phone` also tested with `validate_presence_of`? It isn't, but the factory always generates a phone, and we know from the Store model that phone normalization and validation is required. I added it anyway because the model would be broken without it — but the test file didn't explicitly demand it.

---

## Lines 7–9: `allow_value` matchers

```ruby
should allow_value("admin").for(:role)
should allow_value("manager").for(:role)
should allow_value("employee").for(:role)
```

These say: "setting role to these three string values should be valid." That immediately tells me role is not a free-form text field — it's a **controlled list of exactly three values**. You can't have role = "intern" or role = "janitor."

In Rails there's a feature built exactly for this called `enum`. So the model needed something like:

```ruby
enum :role, { employee: ..., manager: ..., admin: ... }
```

But I still didn't know two things: what values to store in the database, or whether the default should be "employee." Tests A and B answered both of those.

---

## Test A

```ruby
assert_equal({"employee" => 1, "manager" => 2, "admin" => 3}, Employee.roles)
```

`Employee.roles` is a class method that Rails **automatically creates** when you use `enum`. It returns a hash showing you the full mapping of names to stored values. This test tells me exactly what that mapping must look like: `"employee"` maps to `1`, `"manager"` to `2`, `"admin"` to `3`.

That means the database stores **integers** — not strings like `"admin"` or `"manager"`. So this is an integer-backed enum:

```ruby
enum :role, { employee: 1, manager: 2, admin: 3 }, ...
```

This also forced a **migration change**. The original migration created role as a `string` column with default `"employee"`. But with integer-backed enum, the database needs to store `1`, `2`, or `3` — not text. So I had to write a new migration to change the column type to `integer` with a default of `1` (which maps to "employee").

---

## Test B

```ruby
vy = Employee.new
assert_equal "employee", vy.role
```

This creates a brand new employee object without setting any attributes and checks that `role` is already `"employee"`.

Two things had to be true for this to pass:
1. The database column needed a default value of `1` (since 1 maps to "employee" in our enum).
2. The `enum` mapping needed to translate that integer `1` back to the string `"employee"` when you read it.

Rails enum does that translation automatically. When you call `employee.role`, Rails looks up the integer in the database, finds `1`, and returns the string `"employee"`. When you set `employee.role = "admin"`, Rails looks up "admin" in the mapping, finds `3`, and stores `3`. You as the developer always work with readable strings; the integers are just what gets stored.

---

## Test C

```ruby
profh = Employee.new(role: "admin")
assert profh.respond_to?(:admin_role?)
assert profh.respond_to?(:manager_role?)
assert profh.respond_to?(:employee_role?)
```

`respond_to?` asks: "does this object have a method with this name?" So this test says: every employee must have three boolean methods — `admin_role?`, `manager_role?`, and `employee_role?`.

By default, `enum` creates methods named `admin?`, `manager?`, and `employee?`. But those names aren't what the test wants. The test wants a `_role` suffix on each one.

The fix is a single option on the enum declaration:

```ruby
enum :role, { employee: 1, manager: 2, admin: 3 }, suffix: true
```

`suffix: true` tells Rails to append the attribute name (`_role`) to all the generated methods. So instead of `admin?` you get `admin_role?`, instead of `manager?` you get `manager_role?`, and so on. ✓

---

## Test D

```ruby
steve = FactoryBot.build(:employee, first_name: "Steve",
  last_name: "Crawford", ssn: "084359822")
deny steve.valid?
```

This is running inside the context where `create_employees` has already run. Looking at the context setup, Cindy was created with `ssn: "084-35-9822"`. Steve has `ssn: "084359822"`.

Are those the same? If you strip the dashes from Cindy's SSN — `"084-35-9822"` → `"084359822"` — yes, they're identical. So Steve should be invalid because his SSN is already taken.

This told me three things:

1. **SSN must be unique** → `uniqueness: true` on the ssn validation.
2. **SSN must be normalized** before the uniqueness check runs — otherwise `"084-35-9822"` and `"084359822"` would look like different values to the database, and Steve would appear valid.
3. **The normalization must happen in `before_validation`**, not `before_save` — exactly the same reason as with phone on the Store model.

That's where `before_validation :reformat_ssn` and the private method come from:

```ruby
def reformat_ssn
  self.ssn = ssn.gsub(/[^0-9]/, "") if ssn.present?
end
```

Strip everything that isn't a digit, leaving only the 9-digit number.

---

## Test E

```ruby
assert_equal ["Crawford", "Gruberman", "Heimann", "Waldo"],
  Employee.alphabetical.map{|e| e.last_name}
```

The context has four employees: Ed Gruberman, Cindy Crawford, Chuck Waldo, Alex Heimann. The test expects them sorted by last name: Crawford → Gruberman → Heimann → Waldo.

Simple — I need an `alphabetical` scope that sorts by last name. But employees can share a last name, so I sorted by first name as a tiebreaker:

```ruby
scope :alphabetical, -> { order(:last_name, :first_name) }
```

The test only checks last names, so it doesn't verify the tiebreaker — but it's the right thing to do for correctness.

---

## Test F

```ruby
assert_equal 3, Employee.regulars.size
assert_equal ["Crawford", "Gruberman", "Waldo"],
  Employee.regulars.map{|e| e.last_name}.sort
```

Looking at the context: Ed, Cindy, and Chuck were created with the default factory role (which is `1` = employee). Alex was created with `role: "admin"`. So three employees are "regulars" (role = employee) and one is not.

This tells me I need a `regulars` scope that returns only employees with the `employee` role. Since the enum maps `employee` to integer `1`, I can query by the integer:

```ruby
scope :regulars, -> { where(role: 1) }
```

I also added `managers` and `admins` scopes using `2` and `3` respectively, since they follow the same pattern and would clearly be needed.

---

## Test G

```ruby
create_stores
create_assignments
assert_equal ["Waldo", "Heimann"], Employee.unassigned.map{|e| e.last_name}
destroy_assignments
destroy_stores
```

This one required the most thought. After `create_assignments` runs, the situation is:
- **Ed** has `@assign_ed` with `end_date: nil` → currently assigned
- **Cindy** has `@promote_cindy` with `end_date: nil` → currently assigned
- **Chuck** has no assignments → unassigned
- **Alex** has no assignments → unassigned

So `Employee.unassigned` should return Chuck and Alex. The key insight is: an employee is "unassigned" if they have **no assignment with a nil end_date** (nil end_date means the assignment is still ongoing).

How do you query that in Rails? You find all the `employee_id` values that appear in currently-open assignments, then get all employees who are NOT in that set:

```ruby
scope :unassigned, -> { where.not(id: Assignment.where(end_date: nil).select(:employee_id)) }
```

Breaking that down from the inside out:
- `Assignment.where(end_date: nil)` → all currently-open assignments
- `.select(:employee_id)` → from those, just grab the employee IDs (a subquery)
- `where.not(id: ...)` → give me all employees whose ID is NOT in that list

This is called a **subquery** — a query nested inside another query. Rails translates it into a single efficient SQL statement.

---

## Test H

```ruby
assert_equal "Heimann, Alex", @alex.name
```

Clean and simple. I need an instance method called `name` that returns the employee's name in "Last, First" format. Alex Heimann → `"Heimann, Alex"`.

```ruby
def name
  "#{last_name}, #{first_name}"
end
```

The `#{}` syntax is Ruby **string interpolation** — it evaluates the expression inside the braces and inserts it into the string.

---

## Test I

```ruby
assert @ed.over_18?
deny @cindy.over_18?
```

From the context: Ed was born `19.years.ago` (he's 19), Cindy was born `17.years.ago` (she's 17). So `over_18?` should return `true` for Ed and `false` for Cindy.

The logic: an employee is over 18 if their birthday was **more than 18 years ago** — meaning their date of birth is an **earlier** date than 18 years ago.

```ruby
def over_18?
  date_of_birth <= 18.years.ago.to_date
end
```

On a number line, earlier dates are "smaller." So someone born 19 years ago has a smaller (earlier) date_of_birth than `18.years.ago`, which means `<=` is true → they're over 18. Someone born 17 years ago has a larger (more recent) date_of_birth than `18.years.ago`, so `<=` is false → they're under 18.

---

## Test J

```ruby
assert_equal @assign_ed, @ed.current_assignment
assert_equal @promote_cindy, @cindy.current_assignment
assert_nil @alex.current_assignment
```

This tests a method called `current_assignment` that returns the employee's active (open-ended) assignment, or `nil` if they don't have one.

From the context:
- Ed has one assignment with `end_date: nil` → that's his current one
- Cindy has two assignments: one that ended 6 months ago, and `@promote_cindy` which has `end_date: nil` → the open one is her current one
- Alex has no assignments → should return `nil`

The pattern is the same as the `unassigned` scope: an open assignment has `end_date: nil`. So:

```ruby
def current_assignment
  assignments.where(end_date: nil).first
end
```

`assignments` here refers to this specific employee's assignments (Rails knows to filter by `employee_id` because of the `has_many :assignments` association). `.where(end_date: nil)` narrows it to only open ones. `.first` returns one record or `nil` if none exist — which is exactly what the `assert_nil @alex.current_assignment` line expects.
