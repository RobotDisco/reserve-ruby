#!/usr/bin/env ruby

require 'sinatra'
require 'firebase'

set :bind, '0.0.0.0'
set :logging, true

FIREBASE_URL = 'https://dazzling-fire-7049.firebaseio.com/'
firebase = Firebase::Client.new(FIREBASE_URL)

get '/whoowns' do
  return "'server' param not provided." unless params.key? 'server'

  servers = firebase.get('servers')
  owners = firebase.get('users')

  server_name = params['server']
  unless servers.body.key? server_name
    return "server '#{server_name}' not found."
  end
  owner_id = servers.body[server_name]['owner']
  owner_name = owners.body[owner_id.to_i]

  "#{server_name} is owned by #{owner_name}."
end

post '/reserve' do
  unless params.key?('server') && params.key?('owner')
    return "'server' or 'owner' params not provided.'"
  end

  servers = firebase.get('servers')
  owners = firebase.get('users')

  server_name = params['server']
  unless servers.body.key? server_name
    return "server '#{server_name}' not found."
  end

  owner_id = owners.body.find_index(params['owner'].downcase)
  return "user '#{params['owner']}' not found." if owner_id.nil?

  firebase.set("servers/#{server_name}", {isInUse: true, owner: owner_id })

  "Server #{server_name} is now owned by #{params['owner']}"
end

post '/disown' do
  return "'server' param not provided." unless params.key? 'server'

  servers = firebase.get('servers')
  owners = firebase.get('users')

  server_name = params['server']
  unless servers.body.key? server_name
    return "server '#{server_name}' not found."
  end

  owner_id = owners.body.find_index('** Free **')

  firebase.set("servers/#{server_name}", {isInUse: true, owner: owner_id })

  "Server #{server_name} is now available for use."
end
