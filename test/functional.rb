#!/usr/bin/env ruby

begin
  require 'rubygems'
  require 'session'
rescue LoadError
  puts "UNABLE TO RUN FUNCTIONAL TESTS"
  puts "No Session Found"
end

if defined?(Session)
  require 'test/session_functional'
end
