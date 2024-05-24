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

  # Receive params: event_name as string, get the users who attended in alphabetical order 
  # Fields: first_name, last_name, email, city_name, country_name
  def attendees_for 
    # Your code here
  end
end
