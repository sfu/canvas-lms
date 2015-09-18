def account_with_admin_logged_in(opts = {})
  account_with_admin(opts)
  user_session(@admin)
end

def account_with_admin(opts = {})
  @account = opts[:account] || Account.default
  account_admin_user(account: @account)
end
