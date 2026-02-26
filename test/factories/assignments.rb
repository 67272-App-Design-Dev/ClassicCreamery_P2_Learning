FactoryBot.define do
  factory :assignment do
    association :store
    association :employee
    start_date { 1.year.ago.to_date }
    end_date { 1.month.ago.to_date }
  end
end
