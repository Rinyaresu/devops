require 'sinatra'
require 'sinatra/json'
require 'pg'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '*',
             methods: %i[get post put delete options],
             headers: :any
  end
end

set :bind, '0.0.0.0'
set :port, 4567

def db
  @db ||= PG.connect(
    host: ENV['DB_HOST'],
    port: ENV['DB_PORT'],
    dbname: ENV['DB_NAME'],
    user: ENV['DB_USER'],
    password: ENV['DB_PASSWORD']
  )
end

def parse_boolean(value)
  return true if value == 't'
  return false if value == 'f'

  value
end

def process_task_row(row)
  row['completed'] = parse_boolean(row['completed'])
  row
end

def simulate_load
  if ENV['SIMULATE_LOAD'] == 'true'
    sleep rand(1.0..2.0)
  else
    sleep rand(0.1..0.2)
  end
end

get '/api/server-id' do
  @active_connections ||= 0
  @active_connections += 1
  simulate_load
  json({
         server_id: ENV['SERVER_ID'],
         load: ENV['SIMULATE_LOAD'] == 'true' ? 'high' : 'normal',
         active_connections: @active_connections
       })
ensure
  @active_connections -= 1
end

get '/api/tasks' do
  tasks = db.exec('SELECT * FROM tasks ORDER BY id').to_a
  json({
         server_id: ENV['SERVER_ID'],
         tasks: tasks
       })
end

post '/api/tasks' do
  data = JSON.parse(request.body.read)
  result = db.exec_params(
    'INSERT INTO tasks (title, completed) VALUES ($1, $2) RETURNING *',
    [data['title'], false]
  )
  json process_task_row(result.first)
end

put '/api/tasks/:id' do
  data = JSON.parse(request.body.read)
  result = db.exec_params(
    'UPDATE tasks SET title = $1, completed = $2 WHERE id = $3 RETURNING *',
    [data['title'], data['completed'], params['id']]
  )
  json process_task_row(result.first)
end

delete '/api/tasks/:id' do
  db.exec_params('DELETE FROM tasks WHERE id = $1', [params['id']])
  status 204
end
