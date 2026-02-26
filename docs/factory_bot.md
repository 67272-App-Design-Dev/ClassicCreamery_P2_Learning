# Why We Chose Contexts Over FactoryBot

A few reasons, in order of importance:

**1. The README told me to.**
The instructions explicitly say: "we expect that you will have a clean context set up and used for all testing, similar to what was done in PATS." That's a direct requirement, not a suggestion. The grading rubric even mentions "steep penalties" for not following clean code practices, and specifically calls out AI-generated tests that don't follow the course's established patterns.

**2. Predictability over flexibility.**
With FactoryBot, especially when using sequences or Faker for random data, you get a different object every run. That's great for catching edge cases in large systems, but it makes tests harder to reason about. With a context, I know *exactly* what's in the database: Bethany is always active, Cleveland is always inactive, and their names always sort B < C < P. Every assertion I write is based on known, stable facts.

**3. The generated factory was obviously wrong out of the box.**
Look at what Rails generated in `test/factories/stores.rb`:

```ruby
factory :store do
  name { "MyString" }
  state { "MyString" }
  zip { "MyString" }
  phone { "MyString" }
  active { false }
end
```

`"MyString"` would fail every format validation we wrote — zip, phone, state inclusion. To make FactoryBot useful here, you'd have to rewrite the whole factory to produce valid data anyway, at which point you've done almost as much work as writing a context, but with more abstraction on top.

**4. Contexts are more transparent for learning.**
A context is just a plain Ruby method with `Store.create!` calls. There's no DSL to learn, no `build` vs `create` vs `build_stubbed` distinction, no trait system to understand. You can read it and immediately know what data exists. For a course setting where clarity is the point, that matters.

---

That said, FactoryBot is genuinely useful and widely used in industry — it shines when you have many models with complex relationships and you want to spin up objects with minimal boilerplate. It's not that contexts are *better*, they were just the right tool for this specific context (pun intended).
