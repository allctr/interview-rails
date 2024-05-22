class EventMarketting
  def initialize(event)
    @event = event
  end

  def process 
    #50 to 100 apis to publish to 
    apis.each { |api| api.publish_event(@event) } 
  end 
end
