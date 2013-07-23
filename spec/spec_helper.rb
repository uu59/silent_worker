# -- coding: utf-8

require "rubygems"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
else
  require 'coveralls'
  Coveralls.wear!
end

require "bundler/setup"
Bundler.require :default, :test
require "rspec-expectations"
require "rspec/matchers/built_in/be"

Dir["./spec/support/**/*.rb"].each{|file| require file }

require File.expand_path("../../lib/silent_worker.rb", __FILE__)
