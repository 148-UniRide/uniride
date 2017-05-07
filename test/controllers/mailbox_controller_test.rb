require 'test_helper'

class MailboxControllerTest < ActionDispatch::IntegrationTest
  test "should get inbox" do
    get mailbox_inbox_url
    assert_response :success
  end

  test "should get sent" do
    get mailbox_sent_url
    assert_response :success
  end

  test "should get trash" do
    get mailbox_trash_url
    assert_response :success
  end

end
