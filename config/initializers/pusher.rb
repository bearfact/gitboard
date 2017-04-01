# config/initializers/pusher.rb
require 'pusher'

Pusher.app_id = '319705'
Pusher.key = 'a7b8ab23cb2cfdbd0f1e'
Pusher.secret = '047b7d2c0009cd41c4e8'
Pusher.logger = Rails.logger
Pusher.encrypted = true

# app/controllers/hello_world_controller.rb
# class HelloWorldController < ApplicationController
#   def hello_world
#     Pusher.trigger('my-channel', 'my-event', {
#       message: 'hello world'
#     })
#   end
# end
