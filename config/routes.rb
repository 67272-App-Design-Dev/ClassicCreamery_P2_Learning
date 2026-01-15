Rails.application.routes.draw do
  # API routing
  scope module: 'api', defaults: {format: 'json'} do
    namespace :v1 do
      # provide the routes for the API here
      # get 'stores', to: 'stores#index', as: :stores
      get 'stores/:id', to: 'stores#detail', as: :stores_detail
      get 'stores/:id/shifts', to: 'stores#shifts', as: :stores_shifts
      post 'stores/:id/add_assignment', to: 'stores#add_assignment', as: :add_assignment
      put 'end_assignment/:id', to: 'stores#end_assignment', as: :end_assignment
      get 'employees_search', to: 'employees#employees_search', as: :search_employees
      get 'pay_grades', to: 'pay_grades#levels', as: :pay_grade_levels
      get 'shifts/:id/jobs_list', to: 'shifts#jobs_list', as: :shift_jobs_list
      post 'shifts/:id/add_job', to: 'shifts#add_job', as: :shift_add_job
      get 'jobs', to: 'jobs#index', as: :jobs


      # get 'stores/:id/shifts', to: 'stores#shifts', as: :stores_shifts
      # post 'stores/:id/notes', to: 'stores#new_note', as: :stores_note
      # post 'stores/:id/add_assignment', to: 'stores#add_assignment', as: :add_assignment
      # put 'end_assignment/:id', to: 'stores#end_assignment', as: :end_assignment
      # put 'drop_shift/:id', to: 'stores#drop_shift', as: :drop_shift


      # get 'employees', to: 'employees#index', as: :employees
      # get 'spotlight/:id', to: 'employees#spotlight', as: :employee
      # get 'stores/:id/upcoming', to: 'shifts#upcoming', as: :upcoming_shifts
      # get 'shifts/:id', to: 'shifts#show', as: :shift
    end
  end

  # Routes for regular HTML views go here...
  # Semi-static page routes
  get 'home', to: 'home#index', as: :home
  get 'home/about', to: 'home#about', as: :about
  get 'home/contact', to: 'home#contact', as: :contact
  get 'home/privacy', to: 'home#privacy', as: :privacy
  get 'home/search', to: 'home#search', as: :search

  # Authentication routes
  resources :sessions
  get 'login', to: 'sessions#new', as: :login
  get 'logout', to: 'sessions#destroy', as: :logout

  # Resource routes (maps HTTP verbs to controller actions automatically):
  resources :employees
  resources :stores, except: [:destroy]
  resources :assignments
  resources :shifts
  resources :jobs, except: [:show]
  resources :pay_grades, except: [:destroy]
  resources :pay_grade_rates, only: [:new, :create]
  resources :shift_jobs, only: [:new, :create, :destroy]

  # Other custom routes
  get 'employee_form', to: 'payrolls#employee_form', as: :employee_form
  get 'store_form', to: 'payrolls#store_form', as: :store_form
  get 'employee_payroll', to: 'payrolls#employee_report', as: :employee_payroll
  get 'store_payroll', to: 'payrolls#store_report', as: :store_payroll
  get 'time_clock', to: 'shifts#time_clock', as: :time_clock
  patch 'time_in', to: 'shifts#time_in', as: :time_in
  patch 'time_out', to: 'shifts#time_out', as: :time_out

  # Routes for searching
  get 'employees/search', to: 'employees#search', as: :employee_search
  get 'store/search', to: 'store#search', as: :store_search

  # You can have the root of your site routed with 'root'
  root 'home#index'

  
end
