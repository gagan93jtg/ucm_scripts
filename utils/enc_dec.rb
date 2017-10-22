require 'base64'

@secret_key = 'somelongkeyfornoreason'

(0..1).each do |index|
  if(ARGV[index].to_s.empty?)
    puts("\n   Usage: ruby #{__FILE__} option (encrypt/decrypt) string . Example :")
    abort("   ruby #{__FILE__} encrypt my_password")
  end
end

if ARGV[0] == 'encrypt'
  p Base64.encode64(ARGV[1])
else
  p Base64.decode64(ARGV[1])
end
