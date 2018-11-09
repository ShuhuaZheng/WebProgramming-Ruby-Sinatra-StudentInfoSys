require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'


class Users 
	include DataMapper::Resource #include Resource mixin

	property :id, Serial 
	property :firstname, String 
	property :lastname, String
	property :username, String
	property :password, String 
end 

class Students
	include DataMapper::Resource #include Resource mixin

	property :firstname, String 
	property :lastname, String
	property :id, Serial
	property :birthday, Date 
	property :address, Text

end 

class Comments 
	include DataMapper::Resource #include Resource mixin

	property :id, Serial 
	property :name, String 
	property :content, Text 
	property :created_at, DateTime 

end 

DataMapper.finalize 



