Rails.configuration.govpay_api_url = ENV['GOVUK_PAY_API_URL']
Rails.configuration.govpay_api_key = ENV['GOVUK_PAY_API_KEY']
Rails.application.routes.default_url_options[:protocol] = 'https'
