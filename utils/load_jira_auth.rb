require 'json'
require 'base64'

module JiraAuth
	JIRA_AUTH_FILE_PATH = ENV['HOME'] + '/jira_auth.json'

	def self.half_hidden_password
		length = PASSWORD.length
		PASSWORD[0..length/2-1] + Array.new(length/2, 'X').join('')
	end

	begin
		auth = JSON.parse(File.read(JIRA_AUTH_FILE_PATH))
		USERNAME = auth['jira_username']
		PASSWORD = Base64.decode64(auth['jira_encrypted_password'])
		SITE = auth['jira_site']
		puts "Loaded JIRA Credentials. [#{USERNAME}, #{half_hidden_password}, #{SITE}]"
	rescue Errno::ENOENT
		abort ("Error loading file. Probably #{JIRA_AUTH_FILE_PATH} doesn't exist on your system")
	rescue StandardError => e
		abort "Some error loading file "
	end
end
