require "em-websocket"
require "pp"
require "json"

@connections = []

def send_json(message)
  pp message
  @connections.each{|conn|
    pp "sending"
    conn.send(message)
  }
end

MessageItem = Struct.new(:files, :stat)

thread = Thread.new do
  msg = Hash.new
  msg["files"] = Array.new
  0.upto(11){|num|
    msg["files"] << "./black.jpg";
  }
  p "thread alive\n"
  msg["stat"] = "gathering";

  while true do
    sleep 1
    p "thread alive\n"

    if File.exist?("./fig/big.jpg") then
      msg["stat"] = "complete";
      send_json(msg.to_json());
      next
    end

    asemble_flag = true
    0.upto(11){|num|
      filename = "./fig/fig" + num.to_s + ".jpg"
      p filename
      if File.exist?(filename) == true then
        msg["files"][num] = filename;
      else
        msg["files"][num] = "./black.jpg"
        asemble_flag = false
      end
    }

    if asemble_flag == true then
      msg["stat"] = "assembling"
    else
      msg["stat"] = "gathering"
    end

    send_json(msg.to_json());
  end
end

EM::WebSocket.start({:host => "0.0.0.0", :port => 18888}) do |ws_conn|
  ws_conn.onopen do
    @connections << ws_conn
  end

  ws_conn.onmessage do |message|
    pp message
    @connections.each{|conn| conn.send(message)}
  end
end

thread.join
