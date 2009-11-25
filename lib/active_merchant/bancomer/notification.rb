require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Bancomer
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          ['Ds_Date', 'Ds_Hour', 'Ds_Amount', 'Ds_Currency',
           'Ds_Order', 'Ds_MerchantCode', 'Ds_Terminal',
           'Ds_Signature', 'Ds_Response', 'Ds_MerchantData',
           'Ds_SecurePayment', 'Ds_TransactionType',
           'Ds_ConsumerLanguage', 'Ds_ErrorCode' ].each do |attr|
            define_method(attr.downcase) do
              params[attr]
            end
          end

          def complete?
            status == '000'
          end

          def item_id
            ds_order
          end

          def transaction_id
            ds_order
          end

          def received_at
            DateTime.strptime("#{ds_date} #{ds_hour}", "%d/%m/%Y %H:%M")
          end

          def security_key
            ds_signature
          end

          def currency
            ds_currency
          end

          def gross
            "%.2f" % (gross_cents / 100.0)
          end

          def gross_cents
            ds_amount.to_i
          end

          # Was this a test transaction?
          def test?
            false
          end

          def status
            ds_response
          end

          SHA1_CHECK_FIELDS = [ 'Ds_Amount', 'Ds_Order', 'Ds_MerchantCode', 'Ds_Currency', 'Ds_Response' ]

          def generate_sha1string
            SHA1_CHECK_FIELDS.map { |key| params[key.to_s] } * "" + @options[:sha1secret]
          end

          def generate_sha1check
            Digest::SHA1.hexdigest(generate_sha1string)
          end

          # Quickpay doesn't do acknowledgements of callback notifications
          # Instead it uses and SHA1 hash of all parameters
          def acknowledge
            generate_sha1check == ds_signature
          end
        end
      end
    end
  end
end
