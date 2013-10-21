#!/usr/bin/env ruby

require_relative '../config/environment'
require 'fcgi'

if defined?(FCGI::Stream::Error)
  $realstderr = STDERR.dup

  class FCGI
    # print exception like ruby does
    def self.printex(e)
      bt = e.backtrace
      btl = bt[1..-1].map { |l| "  from #{l}\n"}.join ''
      $realstderr.print "#{bt[0]}: #{e} (#{e.class})\n#{btl}"
    end

    # rack uses each, and FCGI has an alias each_request for it
    def self.each
      each_request do |request|
        begin
          yield request
        rescue FCGI::Stream::Error => e
          printex(e)
        end
      end
    end
  end
end

class Rack::PathInfoRewriter
  def initialize(app)
    @app = app
  end

  def call(env)
    env.delete('SCRIPT_NAME')
    parts = env['REQUEST_URI'].split('?')
    env['PATH_INFO'] = parts[0]
    env['QUERY_STRING'] = parts[1].to_s
    @app.call(env)
  end
end

Rack::Handler::FastCGI.run  Rack::PathInfoRewriter.new(Sudu::Application)
