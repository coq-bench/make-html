# Generate an HTML website from a Coq bench database.
require 'erb'
require 'fileutils'
require_relative 'database'
include(ERB::Util)

class Numeric
  # Pretty-print a duration in seconds.
  def duration
    secs  = self.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days} d and #{hours % 24} h"
    elsif hours > 0
      "#{hours} h #{mins % 60} m"
    elsif mins > 0
      "#{mins} m #{secs % 60} s"
    elsif secs >= 0
      "#{secs} s"
    end
  end

  # Pretty-print a file size in kilo-bytes.
  def file_size
    size = self.to_int
    if size == 0 then
      "0 K"
    elsif size < 1024 then
      "1 K"
    elsif size < 1024 * 1024 then
      "#{(size / 1024.0).round} K"
    else
      "#{(size / (1024.0 * 1024.0)).round} M"
    end
  end
end

unless ARGV.size == 2 then
  puts "Usage: ruby make_html.rb database_path html_path"
  exit(1)
end

database_path, install_path = ARGV[0], ARGV[1]

FileUtils.mkdir_p(install_path)

# Copy the CSS and JavaScript.
FileUtils.cp([
  "bootstrap-custom.css",
  "bootstrap.min.css",
  "bootstrap.min.js",
  "favicon.png",
  "moment.min.js"
], install_path)

# Prepare the databases.
databases = {
  clean: Database.new("#{database_path}/clean"),
  tree: Database.new("#{database_path}/tree")}

# Number of generated HTML files.
$nb_generated = 0

def write_in_file(file_name, renderer)
  content = renderer.result().gsub(/\n\s*\n/, "\n")
  unless File.exists?(file_name) && File.read(file_name, encoding: "binary") == content then
    File.open(file_name, "w") do |file|
      file << content
    end
    puts file_name
    $nb_generated += 1
  end
end

# Generate the index.
renderer = ERB.new(File.read("index.html.erb", encoding: "binary"))
write_in_file("#{install_path}/index.html", renderer)

for mode in [:clean, :tree] do
  database = databases[mode]

  # Generate the tables of results.
  renderer = ERB.new(File.read("table.html.erb", encoding: "binary"))
  for architecture in database.architectures do
    for repository in Database.repositories do
      folder_name = "#{install_path}/#{mode}/#{architecture}/#{repository}"
      FileUtils.mkdir_p(folder_name)
      write_in_file("#{folder_name}/index.html", renderer)
    end
  end

  # Generate the logs for each package.
  for architecture in database.architectures do
    for repository in Database.repositories do
      for coq_version in database.coq_versions(architecture, repository) do
        time = database.in_memory[architecture][repository][coq_version][:time]
        results = database.in_memory[architecture][repository][coq_version][:results]
        for name, results in results do
          for version, result in results do
            folder_name = "#{install_path}/#{mode}/#{architecture}/#{repository}/#{coq_version}/#{name}"
            FileUtils.mkdir_p(folder_name)
            renderer = ERB.new(File.read("logs.html.erb", encoding: "binary"))
            write_in_file("#{folder_name}/#{version}.html", renderer)
          end
        end
      end
    end
  end
end

puts "#{$nb_generated} generated or updated HTML files."
