# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.identifier = "org.tinymon.TinyMon"
  app.name = 'TinyMon'
  app.files = Dir.glob("lib/**/*.rb") + app.files
  
  app.development do
    app.testflight do
      app.testflight.sdk = 'vendor/TestFlight'
      app.testflight.api_token = 'apitoken'
      app.testflight.team_token = 'teamtoken'
    end
  end
end
