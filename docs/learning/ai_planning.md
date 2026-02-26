# ClassicCreamery Phase 2 — AI Planning Notes

## Current State
- Rails 8.1.1 / Ruby 3.4.7 project is initialized
- `schema.rb` is empty — no tables yet
- Only `ApplicationRecord` exists as a model
- Test framework is configured (minitest + shoulda-matchers + simplecov + factory_bot)
- No model files, no migrations, no tests exist yet

---

## Recommended Implementation Plan

### Step 1 — Generate the three models with migrations
Use `rails generate model` (not scaffold) for each:
- `Store`: name, street, city, state, zip, phone, active (boolean)
- `Employee`: first_name, last_name, phone, ssn, date_of_birth, role, active (boolean)
- `Assignment`: store:references, employee:references, start_date, end_date

### Step 2 — Run and verify migrations
Run `rails db:migrate` and check the schema looks correct before writing any model logic.

### Step 3 — Build the Store model
In this order within the file:
1. Associations (`has_many :assignments`, `has_many :employees, through: :assignments`)
2. Validations (name uniqueness case-insensitive, zip regex, phone regex, state inclusion, street/city presence)
3. Before-save callback to strip phone down to 10 digits
4. Scopes (`active`, `inactive`, `alphabetical`)
5. Instance methods (`make_active`, `make_inactive`)

### Step 4 — Build the Employee model
1. Associations
2. Validations (name, phone/ssn format, uniqueness of ssn, date_of_birth with `validates_timeliness` for 14-years-ago check)
3. Before-save callbacks to normalize phone and ssn
4. Scopes (active, inactive, alphabetical, is_18_or_older, younger_than_18, regulars, managers, admins, search)
5. Instance methods (name, proper_name, current_assignment, over_18?, make_active, make_inactive, role boolean helpers like `manager_role?`)

### Step 5 — Build the Assignment model
1. Associations (`belongs_to :store`, `belongs_to :employee`)
2. Validations (start_date present + on/before today, end_date after start_date, active store, active employee — validated with custom validators)
3. `before_create` callback to auto-end employee's current assignment
4. Scopes (current, past, by_store, by_employee, chronological, for_store, for_employee, for_role, for_date)

### Step 6 — Set up the test context
Create `test/contexts.rb` with a clean set of reusable test data (stores, employees, assignments in known states), then uncomment `include Contexts` in `test_helper.rb`. This is the "clean context" approach mentioned in the README.

### Step 7 — Write Store tests
Organized sections: relationships, validations (each field), scopes, methods. Run and verify coverage.

### Step 8 — Write Employee tests
Same structure. The `search` scope, role booleans, and `current_assignment` method need careful coverage.

### Step 9 — Write Assignment tests
Focus on: the before_create callback behavior, the `for_date` scope, the `current`/`past` scopes, and validation of active store/employee.

### Step 10 — Verify 100% coverage
Run `rails test` and open the SimpleCov HTML report to find any gaps, then add targeted tests for missed lines.

---

## Key Things to Watch For
- **Phone/SSN normalization** happens in a `before_save` callback — strip everything non-numeric and keep 10 (or 9) digits
- **`validates_timeliness`** is already in the Gemfile — use it for date_of_birth and assignment date validations
- **Assignment's `current_assignment` scope** needs to match what `Employee#current_assignment` calls — keep them in sync
- **`contexts.rb`** is the right approach over FactoryBot factories, based on the PATS reference in the README
- Build and test **one model at a time** rather than all three models then all tests — easier to debug
