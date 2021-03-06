class Admin::EventRegistrationsController < ApplicationController
  # GET /event_registrations/1
  # GET /event_registrations/1.json
  def index
    @event = Event.find(params[:event_id])
    @registrations = @event.registrations

    respond_to do |format|
      format.html
      format.csv { render text: @event.registrations.order("created_at").to_csv }
    end
  end

  def destroy
    @event = Event.find(params[:event_id])
    @registration = @event.registrations.find(params[:id])

    if @registration.destroy then
      redirect_to admin_event_event_registrations_path(@event), :message => "Unregistered successfully"
    else
      redirect_to admin_event_event_registrations_path(@event), :message => "Unable to unregister successfully"      
    end
  end
end