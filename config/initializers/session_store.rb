# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_IIIaquarii_session',
  :secret => 'd6fb64ec73fb2275b1335fd0fc841c8d4e74f673f15873ba8db92f3ff7cbe30c992d90717bbb171f2cab848825680b11d2132f63ad6c47dae6eb364dc1e765f0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
