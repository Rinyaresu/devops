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

get '/api/tasks' do
  json db.exec('SELECT * FROM tasks ORDER BY id').to_a
end

post '/api/tasks' do
  data = JSON.parse(request.body.read)
  result = db.exec_params(
    'INSERT INTO tasks (title, completed) VALUES ($1, $2) RETURNING *',
    [data['title'], false]
  )
  json result.first
end

put '/api/tasks/:id' do
  data = JSON.parse(request.body.read)
  result = db.exec_params(
    'UPDATE tasks SET title = $1, completed = $2 WHERE id = $3 RETURNING *',
    [data['title'], data['completed'], params['id']]
  )
  json result.first
end

delete '/api/tasks/:id' do
  db.exec_params('DELETE FROM tasks WHERE id = $1', [params['id']])
  status 204
end
