# encoding: utf-8
# Depends on the system command `zulip-send`, which we can install with:
# ```
# pip install zulip
# ```
require 'erb'
require_relative 'database'

include(ERB::Util)

unless ARGV.size == 6 then
  puts "Usage: ruby push_to_zulip.rb database_path user token_path stream subject nb_hours"
  exit(1)
end

database_path, user, token_path, stream, subject, nb_hours =
  ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4], ARGV[5].to_i

def puts_ok
  puts " \e[1m\e[32mOK\e[0m"
end

print "Fetching the last bench results..."
database = Database.new("#{database_path}/clean")
benches = database.get_benches_of_the_past_hours(nb_hours, "released")
puts_ok

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
message << ">\n"
message << "> #{nb_package_versions} package installations, #{nb_errors} error#{nb_errors != 1 ? "s" : ""}, #{"%.2f" % (nb_package_versions != 0 ? 100 * (nb_errors.to_f / nb_package_versions.to_f) : 0)}% errors#{nb_errors == 0 ? " ✅" : ""}\n"
puts message

print "Sending a message with a summary of the last bench..."
max_message_lines = 10
next_message_lines = message.split("\n")
token = File.read(token_path)
while next_message_lines.size != 0 do
  current_message_lines = next_message_lines[0..max_message_lines - 1]
  next_message_lines = next_message_lines[max_message_lines..-1] || []
  message_stub = current_message_lines.join("\n")
  system(
    "zulip-send",
    "--api-key", token,
    "--user", user,
    "--site", "coq.zulipchat.com",
    "--message", message_stub,
    "--stream", stream,
    "--subject", subject
  )
end
puts_ok
