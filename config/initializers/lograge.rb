Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.custom_options = lambda do |event|
    exceptions = ['controller', 'action', 'format', 'id']
    {
      time: event.time,
      params: event.payload[:params].except(*exceptions)
    }
  end
end
