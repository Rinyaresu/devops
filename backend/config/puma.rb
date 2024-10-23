workers 2
threads_count = 5
threads threads_count, threads_count

port        ENV.fetch('PORT') { 4567 }
environment ENV.fetch('RACK_ENV') { 'development' }

plugin :tmp_restart
