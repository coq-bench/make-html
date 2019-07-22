require 'gitter'
require_relative 'database'

unless ARGV.size == 3 then
  puts "Usage: ruby push_to_gitter.rb database_path token_path room_name"
  exit(1)
end

database_path, token_path, room_name = ARGV[0], ARGV[1], ARGV[2]

def puts_ok
  puts " \e[1m\e[32mOK\e[0m"
end

print "Connecting to Gitter..."
token = File.read(token_path)
client = Gitter::Client.new(token)
room_id = client.rooms.find {|room| room.name == room_name}.id
puts_ok

print "Fetching the last bench results..."
database = Database.new("#{database_path}/clean")
last_bench = database.get_last_bench
puts_ok

print "Sending a message with a summary of the last bench..."
arch, ocaml, opam = /\A(.*)-([^\-]*)-([^\-]*)\z/.match(last_bench[:architecture]).captures
client.send_message("Bench results on Coq #{last_bench[:coq]}, OCaml #{ocaml} (#{arch}, opam #{opam}):", room_id)
client.send_message("#{last_bench[:bench][:results].size} packages", room_id)

puts_ok
