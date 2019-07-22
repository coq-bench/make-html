require 'erb'
require 'gitter'
require_relative 'database'

include(ERB::Util)

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
message = "> **Bench report on OCaml #{ocaml}, Coq #{last_bench[:coq]}**\n"
error_message = ""
nb_errors = 0
nb_package_versions = 0
for package_name, versions in last_bench[:bench][:results] do
  for package_version, result in versions do
    nb_package_versions += 1
    error_symbol = result.status.unicode_error_symbol
    if error_symbol then
      nb_errors += 1
      url = "https://coq-bench.github.io/clean/#{u(last_bench[:architecture])}/#{u(last_bench[:repository])}/#{u(last_bench[:coq])}/#{u(package_name)}/#{u(package_version)}.html"
      error_message << "> * [coq-#{package_name} #{package_version}](#{url}) #{error_symbol} (#{result.long_message.downcase})\n"
    end
  end
end
message << error_message
message << ">\n"
message << "> #{nb_package_versions} package versions, #{nb_errors} error#{nb_errors != 1 ? "s" : ""}#{nb_errors == 0 ? " ✅" : ""}\n"
client.send_message(message, room_id)

puts_ok
