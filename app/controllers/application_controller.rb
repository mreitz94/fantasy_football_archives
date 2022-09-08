class ApplicationController < ActionController::Base
  private

  def resource
    nil
  end

  def league_shareable?
    @league.try(:shareable?)
  end

  def authenticate_resource_access!
    return if resource.blank?

    if current_user.nil? || !current_user.own_resource?(resource)
      redirect_to root_path
    end
  end
end
