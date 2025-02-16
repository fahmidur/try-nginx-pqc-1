require 'webrick'
require 'json'
require 'time'

root = File.expand_path('./public')
server = WEBrick::HTTPServer.new(:Port => 8083, :DocumentRoot => root)


trap 'INT' do server.shutdown end

server.mount_proc '/' do |req, res|
  res['Content-Type'] = 'application/json';
  req_headers = {}
  req.each do |k,v|
    req_headers[k] = v
  end
  now = Time.now
  data = {
    :method => req.request_method,
    :request_ip => req['x-real-ip'],
    :request_url => req.path,
    :headers => req_headers,
    :now => {
      :utc_str => now.utc.to_s,
      :iso_str => now.to_s,
    }
  }
  res.body = data.to_json
end

server.start


