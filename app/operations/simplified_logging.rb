module SimplifiedLogging
  def log_error(source, code, message)
    Rails.logger.error(
      {
        source: source,
        error_code: code,
        error_message: message
      }.to_a.map { |x| x.join('=') }.join(' ')
    )
  end
end
