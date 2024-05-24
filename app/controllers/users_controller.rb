class UsersController < ApplicationController

  # Returns first 100 users in no specific order
  # Fields: first_name, last_name, email
  #
  def all_users
    users = User.limit(100)

    users = users.map do |u|
        {
          first_name: u.first_name,
          last_name: u.last_name,
          email: u.email
        }
      end
    render json: { status: 'success', users: users }
  end
end
