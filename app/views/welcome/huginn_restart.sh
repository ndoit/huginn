kill -9 $(cat /tmp/huginn.pid )
cd /vagrant/apps/huginn/ && bundle && puma -w 4 -p 3001 --pidfile /tmp/huginn.pid -d -C /vagrant/huginn.conf
