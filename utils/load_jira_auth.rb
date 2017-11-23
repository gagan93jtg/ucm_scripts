require 'json'
require 'base64'

module JiraAuth
  def self.half_hidden_password
    length = PASSWORD.length
    PASSWORD[0..length / 2 - 1] + Array.new(length / 2, 'X').join('')
  end

  begin
    if File.exists?('../configuration/global_config.rb')
      require_relative('../configuration/global_config.rb')
      JIRA_AUTH_FILE_PATH = GlobalConfig::JIRA_AUTH_JSON_PATH
    else
      JIRA_AUTH_FILE_PATH = ENV['HOME'] + '/jira_auth.json'
    end

    auth = JSON.parse(File.read(JIRA_AUTH_FILE_PATH))
    USERNAME = auth['jira_username']
    PASSWORD = Base64.decode64(auth['jira_encrypted_password'])
    SITE = auth['jira_site']
    puts "[Load JIRA Auth] Loaded JIRA Credentials. [#{USERNAME}, #{half_hidden_password}, #{SITE}]"
  rescue Errno::ENOENT
    abort "[Load JIRA Auth] Error loading file. Probably #{JIRA_AUTH_FILE_PATH} doesn't exist on your system"
  rescue StandardError => e
    abort "[Load JIRA Auth] Some error loading file/data [#{e.message}]"
  end
end
