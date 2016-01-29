require 'active_support/deprecation'

module ExceptionNotifier
  class Notifier
    
    ExceptionNotifier::Notifier.class_eval do
      #https://github.com/smartinez87/exception_notification/blob/master/lib/exception_notifier/notifier.rb
      def self.exception_notification(*args)
        message = super
        
        _limit = 5.minutes.ago
        @@last_notification||=_limit 
        if @@last_notification > _limit
          Rails.logger.info "ExceptionNotifier rate limit triggered, #{ExceptionNotifier::Notifier.deliveries.size} notifications limited."
          message.delivery_method :test
        else
          @@last_notification = Time.now
        end
        
        message
      end
    end

    def self.exception_notification(env, exception, options={})
      ActiveSupport::Deprecation.warn "Please use ExceptionNotifier.notify_exception(exception, options.merge(:env => env))."
      ExceptionNotifier.registered_exception_notifier(:email).create_email(exception, options.merge(:env => env))
    end

    def self.background_exception_notification(exception, options={})
      ActiveSupport::Deprecation.warn "Please use ExceptionNotifier.notify_exception(exception, options)."
      ExceptionNotifier.registered_exception_notifier(:email).create_email(exception, options)
    end
  end
end
