#!/usr/bin/env puma
tag                  'api.unitwise.org'
pidfile              '/var/www/api.unitwise.org/tmp/pids/puma.pid'
state_path           '/var/www/api.unitwise.org/tmp/sockets/puma.state'
activate_control_app 'unix:///var/www/api.unitwise.org/tmp/sockets/pumactl.sock'
stdout_redirect      '/var/www/api.unitwise.org/shared/log/puma.stdout.log',
                     '/var/www/api.unitwise.org/shared/log/puma.stderr.log', true
workers              2
threads              0, 16
bind                 'unix:///var/www/api.unitwise.org/tmp/sockets/puma.sock'
daemonize
prune_bundler