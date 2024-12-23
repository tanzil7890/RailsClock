module RailsClocks
  class RecordedRequest < ActiveRecord::Base
    self.table_name = 'railsclocks_recorded_requests'

    validates :uuid, presence: true, uniqueness: true
    validates :recorded_at, presence: true

    scope :recent, -> { order(recorded_at: :desc) }
    
    def replay
      ReplayService.new(self).replay
    end
  end
end 