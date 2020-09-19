class EventsController < ApplicationController
  before_action :authenticate_user, only: %i[create index update destroy register unregister join export_registered export_joined]
  before_action :set_event, only: [:update, :destroy, \
    :register, :unregister, :join, :public_register, :public_join, :export_registered, :export_joined]

  # GET /events
  def index
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @events = Event.all
    
    @events.each do |event|
      event.current_user = current_user
    end
    
    render(json: @events.to_json(methods: [:user_registration]), status: :ok)
  end

  # POST /events
  def create
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @event = Event.new(name: event_params[:name], kind: event_params[:kind])
    @event.description = event_params[:description] if event_params[:description]if event_params[:link]
    if event_params[:link]
      if event_params[:link].start_with?("http://") || event_params[:link].start_with?("https://")
        @event.link = event_params[:link]
      else
        @event.link = 'http://' + event_params[:link]
      end
    end
    if event_params[:kind] == 'open' && event_params[:public_link]
      if event_params[:public_link].start_with?("http://") || event_params[:public_link].start_with?("https://")
        @event.public_link = event_params[:public_link]
      else
        @event.public_link = 'http://' + event_params[:public_link]
      end
    end
    @event.image_url = event_params[:image_url] if event_params[:image_url]
    @event.host = event_params[:host] if event_params[:host]

    @event.start_time = DateTime.iso8601(event_params[:start_time]) if event_params[:start_time]
    @event.end_time = DateTime.iso8601(event_params[:end_time]) if event_params[:end_time]

    if @event.save

      if @event.kind === 'invite-only' && event_params[:invites]
        event_params[:invitees].each do |email|
          user = User.find_or_create_by(email: email)
          @event.invitations.create!(user: user)
        end
      end

      render(json: @event, status: :created)
    else
      render(json: @event.errors, status: :unprocessable_entity)
    end
  end

  # PUT /events/:event_id
  def update
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @event.name = event_params[:name] if event_params[:name]
    @event.kind = event_params[:kind] if event_params[:kind]
    @event.description = event_params[:description] if event_params[:description]
    if event_params[:link]
      if event_params[:link].start_with?("http://") || event_params[:link].start_with?("https://")
        @event.link = event_params[:link]
      else
        @event.link = 'http://' + event_params[:link]
      end
    end
    if event_params[:kind] == 'open' && event_params[:public_link]
      if event_params[:public_link].start_with?("http://") || event_params[:public_link].start_with?("https://")
        @event.public_link = event_params[:public_link]
      else
        @event.public_link = 'http://' + event_params[:public_link]
      end
    end
    @event.image_url = event_params[:image_url] if event_params[:image_url]
    @event.host = event_params[:host] if event_params[:host]

    @event.start_time = DateTime.iso8601(event_params[:start_time]) if event_params[:start_time]
    @event.end_time = DateTime.iso8601(event_params[:end_time]) if event_params[:end_time]

    if @event.save

      if @event.kind === 'invite-only' && event_params[:invites]
        event_params[:invitees].each do |email|
          user = User.find_or_create_by(email: email)
          @event.invitations.create!(user: user)
        end
      end

      render(json: @event, status: :created)
    else
      render(json: @event.errors, status: :unprocessable_entity)
    end
  end

  # DELETE /events/:event_id
  def destroy
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @event.destroy

    render(json: { message: 'Successfully deleted' }, status: :ok)
  end

  # GET /events/public
  def public
    @public_events = Event.where(kind: 'open')
    render(json: @public_events, status: :ok)
  end

  # POST /events/:id/register
  def register
    @registration = @event.registrations.find_or_create_by(user: current_user)

    @registration.registered = true

    if @registration.save
      @event.current_user = current_user

      render(json: @event.to_json(methods: [:user_registration]), status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/unregister
  def unregister
    @registration = @event.registrations.find_or_create_by(user: current_user)

    @registration.registered = false

    if @registration.save
      @event.current_user = current_user

      render(json: @event.to_json(methods: [:user_registration]), status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/public_register
  def public_register
    render(json: { message: 'Not a public event' }) if @event.kind != 'open'

    @registration = @event.registrations.find_or_create_by(ip_address: request.remote_ip.to_s)

    @registration.update(public_name: event_params[:public_name], public_email: event_params[:public_email], registered: true)

    if @registration.save
      render(json: @registration, status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/join
  def join
    @registration = @event.registrations.find_or_create_by(user: current_user)

    @registration.joined = true

    if @registration.save
      @event.current_user = current_user

      render(json: @event.to_json(methods: [:user_registration]), status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/public_join
  def public_join
    @registration = @event.registrations.find_or_create_by(ip_address: request.remote_ip.to_s)

    @registration.joined = false

    if @registration.save
      render(json: @registration, status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end
  
  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.permit([:name, :description, :link, :kind, :start_time, :end_time, :image_url, :host, :public_link, \
      :public_name, :public_email, :public_link, invites: []])
  end
  
end
