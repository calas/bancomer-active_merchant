require "helper"

class BancomerModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_notification_method
    assert_instance_of Bancomer::Notification, Bancomer.notification('name=cody')
  end
end

class BancomerHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = Bancomer::Helper.new('R987654321','1234567', :amount => 5.00)
    @helper.sha1secret "mysecretsha1string"
    @helper.return_url 'http://example.com/ok'
    @helper.cancel_return_url 'http://example.com/cancel'
    @helper.notify_url 'http://example.com/notify'
    @helper.description 'Product Description'
  end

  def test_basic_helper_fields
    assert_field 'Ds_Merchant_MerchantCode', '1234567'
    assert_field 'Ds_Merchant_Amount',       '500'
    assert_field 'Ds_Merchant_Order',        '000987654321'
    assert_field 'Ds_Merchant_UrlOk',        'http://example.com/ok'
    assert_field 'Ds_Merchant_UrlKo',        'http://example.com/cancel'
    assert_field 'Ds_Merchant_MerchantURL',  'http://example.com/notify'
    assert_field 'Ds_Merchant_ProductDescription',  'Product Description'
  end

  def test_minimum_fields
    assert @helper.form_fields.size >= 9
  end

  def test_secret_generation
    assert_not_nil @helper.form_fields['Ds_Merchant_MerchantSignature']
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end

  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end

class BancomerNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @bancomer = Bancomer::Notification.new(http_raw_data, :sha1secret => "mysecretsha1string")
  end

  def test_accessors
    assert @bancomer.complete?
    assert_equal "000", @bancomer.status
    assert_equal "000987654321", @bancomer.transaction_id
    assert_equal "000987654321", @bancomer.item_id
    assert_equal "5.00", @bancomer.gross
    assert_equal "484", @bancomer.currency
    assert_equal DateTime.parse('2009 Feb 2, 10:25'), @bancomer.received_at
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement
    assert @bancomer.acknowledge
  end

  def test_respond_to_acknowledge
    assert @bancomer.respond_to?(:acknowledge)
  end

  private

  # Digest::SHA1.hexdigest("5000009876543211234567484000mysecretsha1string")
  def http_raw_data
    "Ds_Date=02%2F02%2F2009&Ds_Hour=10:25&Ds_Amount=500" +
      "&Ds_Currency=484&Ds_Order=000987654321&Ds_MerchantCode=1234567" +
      "&Ds_Terminal=1&Ds_Signature=4ab324115ec93c45a969656dda0f1d6aa79e807a" +
      "&Ds_Response=000&Ds_MerchantData=&Ds_SecurePayment=1" +
      "&Ds_TransactionType=0&Ds_ConsumerLanguage=0"
  end

end
