require 'erb'
require 'gitter'
require_relative 'database'

include(ERB::Util)

unless ARGV.size == 4 then
  puts "Usage: ruby push_to_gitter.rb database_path token_path room_name nb_hours"
  exit(1)
end

database_path, token_path, room_name, nb_hours = ARGV[0], ARGV[1], ARGV[2], ARGV[3].to_i

def puts_ok
  puts " \e[1m\e[32mOK\e[0m"
end

print "Connecting to Gitter..."
token = File.read(token_path)
client = Gitter::Client.new(token)
room = client.rooms.find {|room| room.name == room_name}
if room.nil?
  puts "Unable to connect find the room '#{room_name}'"
  exit(1)
end
room_id = room.id
puts_ok

print "Fetching the last bench results..."
database = Database.new("#{database_path}/clean")
benches = database.get_benches_of_the_past_hours(nb_hours, "released")
puts_ok

print "Sending a message with a summary of the last bench..."
message = "> Summary of the past #{nb_hours} hours:\n"
nb_package_versions = 0
nb_errors = 0
package_error_messages = {}
for bench in benches do
  for package_name, versions in bench[:results] do
    for package_version, result in versions do
      nb_package_versions += 1
      package_full_name = "#{package_name}.#{package_version}"
      error_symbol = result.status.unicode_error_symbol
      if error_symbol then
        nb_errors += 1
        _, ocaml, _ = /\A(.*)-([^\-]*)-([^\-]*)\z/.match(bench[:architecture]).captures
        url = "https://coq-bench.github.io/clean/#{u(bench[:architecture])}/#{u(bench[:repository])}/#{u(bench[:coq])}/#{u(package_name)}/#{u(package_version)}.html"
        package_error_messages[package_full_name] ||= []
        package_error_messages[package_full_name] << ">   * [Coq #{bench[:coq]}, OCaml #{ocaml}](#{url}) #{error_symbol} (#{result.long_message.downcase})"
      end
    end
  end
end
for package_full_name, error_messages in package_error_messages.sort do
  message << "> * #{package_full_name}:\n"
  message << error_messages.sort.join("\n")
  message << "\n"
end
message << "> #{nb_package_versions} tested package versions, #{nb_errors} error#{nb_errors != 1 ? "s" : ""}, #{"%.2f" % (nb_package_versions != 0 ? 100 * (nb_errors.to_f / nb_package_versions.to_f) : 0)}% errors#{nb_errors == 0 ? " ✅" : ""}\n"
client.send_message(message, room_id)
puts_ok
puts message
