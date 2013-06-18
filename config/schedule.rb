
every 1.day, :at => '8:40 pm' do
#  runner "MyModel.some_process"
#  rake "my:rake:task"
#  command "/usr/bin/my_great_command" 

  rake "db:backup_mysql_db MAX=50 DIR=/home/backup/db/rails3extjs4demo/"
end
