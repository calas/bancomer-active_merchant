require "money"
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Bancomer
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          def initialize(order, account, options = {})
            super
            add_field('Ds_Merchant_Currency', 484)
            add_field('Ds_Merchant_TransactionType', 0)
            add_field('Ds_Merchant_Order', format_order_number(order))
            add_field('Ds_Merchant_MerchantCode', account)
            add_field('Ds_Merchant_Terminal', 1)
            add_field('Ds_Merchant_Amount', options[:amount].to_money.cents.to_i)
          end

          # Limited to 12 digits max
          def format_order_number(number)
            number.to_s.gsub(/[A-Z]/, '').rjust(12, "0")
          end

          def sha1secret(value)
            @sha1secret = value
          end

          def form_fields
            @fields.merge('Ds_Merchant_MerchantSignature' => generate_sha1check)
          end

          def generate_sha1string
            SHA1_CHECK_FIELDS.map {|key| @fields[key.to_s]} * "" + @sha1secret
          end

          def generate_sha1check
            Digest::SHA1.hexdigest(generate_sha1string)
          end

          SHA1_CHECK_FIELDS = [ 'Ds_Merchant_Amount', 'Ds_Merchant_Order',
                                'Ds_Merchant_MerchantCode', 'Ds_Merchant_Currency',
                                'Ds_Merchant_TransactionType' ]

          mapping :notify_url, 'Ds_Merchant_MerchantURL'
          mapping :return_url, 'Ds_Merchant_UrlOk'
          mapping :cancel_return_url, 'Ds_Merchant_UrlKo'
          mapping :description, 'Ds_Merchant_ProductDescription'
        end
      end
    end
  end
end
