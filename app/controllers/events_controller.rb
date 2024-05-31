class EventsController < ApplicationController
  # List the first 100 events in descending order
  #
  #
  def index
    @events = Event.order(event_date: :desc).limit(100)

    events = @events.map do |event|
        {
          name: event.name,
          date: event.event_date.strftime("%d %b %Y"),
        }
      end
    render json: { status: :success, events: events }
  end

  # Receive params: year as integer, list the top 100 events, starting from the most recent ones
  # Fields: name, event_date, city_name, country_name
  def all_in_year 
    # Your code here 
  end
end
