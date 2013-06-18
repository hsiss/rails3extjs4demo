#备份mysql数据库
#rake db:backup_mysql_db RAILS_ENV=production MAX=50 DIR="/var/backup/" 
#cd /path/to/rails/app && /opt/csw/bin/rake cron:dummy
require 'find'
namespace :db do
  desc "Backup the database to a file. Options: DIR=base_dir RAILS_ENV=production MAX=20"
  task :backup_mysql_db => [:environment] do
    datestamp = Time.now.strftime("%Y%m%d%H%M%S")
    base_path = ENV["DIR"] || "db"
    backup_base = File.join(base_path, 'backup')
    backup_folder = backup_base

    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    FileUtils.mkdir_p(backup_folder)
    backup_file = File.join(backup_folder, "#{db_config['database']}.#{RAILS_ENV}.#{datestamp}.sql")
    cmd = "mysqldump -u#{db_config['username']} -p#{db_config['password']} #{db_config['database']} --opt  > #{backup_file}" 
    puts cmd 
    system(cmd)
    dir = Dir.new(backup_base)
    all_backups = dir.entries[2..-1].sort.reverse
    puts "Created backup: #{backup_file}"
    puts "#{all_backups.length} backups available"
  end
end
