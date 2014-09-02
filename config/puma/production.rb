#!/usr/bin/env puma
tag                  'api.unitwise.org'
directory            '/var/www/api.unitwise.org/current'
pidfile              '/var/www/api.unitwise.org/shared/tmp/pids/puma.pid'
state_path           '/var/www/api.unitwise.org/shared/tmp/sockets/puma.state'
activate_control_app 'unix:///var/www/api.unitwise.org/shared/tmp/sockets/pumactl.sock'
stdout_redirect      '/var/www/api.unitwise.org/shared/log/puma.stdout.log',
                     '/var/www/api.unitwise.org/shared/log/puma.stderr.log', true
workers              1
threads              1, 16
bind                 'unix:///var/www/api.unitwise.org/shared/tmp/sockets/puma.sock'
daemonize
prune_bundler