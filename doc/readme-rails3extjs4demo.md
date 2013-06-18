
# 创建数据库
mysql -u root
执行sql
create database rails3extjs4demo character set utf8;

# 
git clone git@github.com:hsiss/rails3extjs4demo.git
cd rails3extjs4demo
bundle install
rake db:migrate

# 启动服务
rails s -p4002
用浏览器访问localhost:4002


# 更新最新代码
git pull origin master

# 在产品环境更新
service demo stop
bundle exec rake db:migrate
bundle exec rake assets:precompile
service demo start


# 备份数据库的crontab
40 20 * * * root /bin/bash -l -c 'cd /home/apps/demo && bundle exec rake db:backup_mysql_db MAX=50 DIR=/home/backup/db/demo/ --silent'
