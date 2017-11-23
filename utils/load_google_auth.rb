require 'json'
require 'base64'

module JiraAuth
  if File.exists?('../configuration/global_config.rb')
    require_relative('../configuration/global_config.rb')
    GOOGLE_AUTH_JSON_PATH = GlobalConfig::GOOGLE_AUTH_JSON_PATH
  else
    GOOGLE_AUTH_JSON_PATH = ENV['HOME'] + '/google_auth.json'
  end

  puts "[Load Google Auth] Loaded Google auth file path. #{GOOGLE_AUTH_JSON_PATH}"
end
