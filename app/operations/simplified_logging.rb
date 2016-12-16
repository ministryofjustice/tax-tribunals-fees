module SimplifiedLogging
  def log_error(source, code, message, additional = {})
    Rails.logger.error(
      {
        source: source,
        error_code: code,
        error_message: message
      }.merge(additional).to_a.map { |x| x.join('=') }.join(' ')
    )
  end
end
