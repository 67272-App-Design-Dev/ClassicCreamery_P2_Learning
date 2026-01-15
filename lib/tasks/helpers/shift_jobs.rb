module Populator
  module ShiftJobs

    def create_shift_jobs_for_past_shifts
      all_past_shifts = Shift.past.all
      all_jobs = Job.all
      count = 0

      all_past_shifts.each do |shift|
        count += 1
        FactoryBot.create(:shift_job, shift: shift, job: all_jobs.sample) unless count%10 == 0
        puts " -- created #{count} past shift jobs" if (count % 100).zero?
      end
    end

  end
end