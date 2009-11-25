require File.dirname(__FILE__) + '/bancomer/helper.rb'
require File.dirname(__FILE__) + '/bancomer/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Bancomer
        mattr_accessor :service_url

        self.service_url = 'https://www.bancomer.eglobal.com.mx/sis/entradaPagos'

        def self.notification(post)
          Notification.new(post)
        end
      end
    end
  end
end
