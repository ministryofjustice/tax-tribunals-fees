require 'glimr_api_client'
class Healthcheck
  def self.check
    new.check
  end

  def check
    {
      service_status: service_status,
      version: version,
      dependencies: {
        glimr_status: glimr_status,
        database_status: database_status,
        govuk_pay_status: govuk_pay_status
      }
    }
  end

  private

  # {"ping":{"healthy":true},"deadlocks":{"healthy":true}}
  # A bit terse, I know.  Given the current return values from govuk pay,
  # will fail if either fails.
  def govuk_pay_status
    @response ||=
      if JSON.parse(
        Excon.get("#{ENV.fetch('GOVUK_PAY_API_HEALTHCHECK_URL')}").body
      ).values.map(&:values).flatten.all?
        'ok'
      else
        'failed'
      end
  rescue JSON::ParserError
    'failed'
  end

  def version
    # This has been manually checked in a demo app in a docker container running
    # ruby:latest with Docker 1.12. Ymmy, however; in particular it may not
    # work on alpine-based containers. It is mocked at the method level in the
    # specs, so it is possible to simply comment the call out if there are
    # issues with it.
    `git rev-parse HEAD`.chomp
  end

  def database_status
    # This will only catch high-level failures.  PG::ConnectionBad gets
    # raised too early in the stack to rescue here.
    @database_status ||= if ActiveRecord::Base.connection
                           'ok'
                         else
                           'failed'
                         end
  end

  def glimr_status
    @glimr_status ||=
      begin
        if GlimrApiClient::Available.call.available?.eql?(true)
          'ok'
        end
      rescue GlimrApiClient::Unavailable
        'failed'
      end
  end

  def service_status
    if database_status.eql?('ok') &&
       glimr_status.eql?('ok') &&
       govuk_pay_status.eql?('ok')
      'ok'
    else
      'failed'
    end
  end
end
