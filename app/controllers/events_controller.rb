class EventsController < ApplicationController
  # Populate Events necessary to be displayed on the front-end based on each criterion
  def index
    # Write arel here to get the necessary event objects
  end

  def show
    @user = User.find(params[:id])
  end
end
