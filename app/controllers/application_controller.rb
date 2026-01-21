class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  skip_after_action :discard_flash_if_xhr
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  before_action :configure_permitted_parameters, if: :devise_controller?
  
  def guest_user
    @guest_user ||= User.where(guest: true).first || super
  end
  
  # Override Devise's redirect after sign in to avoid redirecting to thumbnails
  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)
    
    # If there's a stored location and it contains thumbnail parameters, clean it
    if stored_location.present? && stored_location.include?('?file=thumbnail')
      # Remove thumbnail parameter and redirect to the clean object URL
      stored_location.split('?').first
    elsif stored_location.present? && stored_location.match?(/\/downloads\//)
      # If the stored location is a download URL, redirect to dashboard instead
      hyrax.dashboard_path
    elsif stored_location.present?
      # Use the stored location if it's clean
      stored_location
    else
      # Default to dashboard
      hyrax.dashboard_path
    end
  end
  
  protected

    #Allows new fields in sign_up an update an account
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :paternal_surname, :maternal_surname, :phone])
      devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :paternal_surname, :maternal_surname, :phone])
    end 

  protect_from_forgery with: :exception
  
end
