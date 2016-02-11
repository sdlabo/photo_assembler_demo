require 'webrick'

WEBrick::HTTPServer.new(:DocumentRoot => "./", :Port => 18000).start
