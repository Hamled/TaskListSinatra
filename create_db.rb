require "./lib/database.rb"

print "Opening database....."
db = TaskList::Database.new("tasklist.db")
puts "done."

print "Creating schema....."
db.create_schema
puts "done."
