#!/usr/bin/env ruby

require 'webrick'
require 'jwt'

require 'net/http'
require 'json'
require 'socket'

client = 'demo'
secret = 'secret'

def seq_log(job)
  xs = job["output"]
  xs.sort_by! {|x| x["serial"]}
  names = xs.map {|x| x["stream"]}.uniq
  log = {}
  names.each do |nn|
    log[nn] = xs.filter {|x| x["stream"] == nn}.map {|x| x["text"]}.join("")
  end
  log
end

root = File.expand_path '.'
server = WEBrick::HTTPServer.new(Port: 8001, DocumentRoot: root)
trap 'INT' do server.shutdown end

server.mount_proc '/result' do |req, res|
  thead = req['Authorization']
  bearer, token = thead.split(/\s+/)
  raise 'not bearer' unless bearer.downcase == "bearer"

  dtok, _hdrs = JWT.decode(token, secret, true, algorithm: 'HS256')
  raise "bad aud" unless dtok['aud'] == 'demo'

  data = JSON.parse(req.body)

  puts JSON.pretty_generate(data)

  log = seq_log(data["job"])
  puts "\n\n== STDOUT =="
  puts log["stdout"]
  puts "\n\n== STDERR =="
  puts log["stderr"]

  res.body = "Hi"
  server.shutdown
end

sthr = Thread.new do
  server.start
end

payload = {
  iss: client,
  aud: "steno",
  action: "create job",
  jobkey: "55",
}
token = JWT.encode payload, secret, 'HS256'

uri = URI("http://localhost:4000/api/jobs")
req = Net::HTTP::Post::new(uri)
req['Accept'] = "application/json; charset=utf-8"
req['Content-Type'] = "application/json"
req['Authorization'] = "Bearer #{token}"

host = Socket.gethostname

job = {
  key: "55",
   pri: 10,
  container: {
    base: "debian:buster",
    packages: ["clang", "clang-tools", "valgrind"],
    user_commands: [
      "curl https://sh.rustup.rs -sSf | sh -s -- -y",
    ],
    size_limit: "10M",
  },
  driver: {
    script: "classic",
    SUB: "http://#{host}:8001/sub.tar.gz",
    GRA: "http://#{host}:8001/gra.tar.gz",
  },
  postback: "http://#{host}:8001/result",
}

req.body = JSON.generate({job: job})

Net::HTTP.start(uri.host, uri.port) do |http|
  resp = http.request(req)
  puts resp.inspect
  puts resp.body
end

sthr.join
