# Generate an HTML website from a Coq bench database.
require 'erb'
require 'fileutils'
require_relative 'database'

unless ARGV.size == 2 then
  puts "Usage: ruby make_html.rb database_path html_path"
  exit(1)
end

database_path, install_path = ARGV[0], ARGV[1]

FileUtils.mkdir_p(install_path)

# Copy the CSS and JavaScript.
FileUtils.cp(["about.html", "bootstrap.min.css", "bootstrap.min.js", "favicon.png", "moment.min.js"], install_path)

# Prepare ERB.
include(ERB::Util)

# Prepare the database.
database = Database.new(database_path)

# Number of generated files.
nb_generated = 0

# Generate the index.
renderer = ERB.new(File.read("index.html.erb", encoding: "binary"))
File.open("#{install_path}/index.html", "w") do |file|
  file << renderer.result().gsub(/\n\s*\n/, "\n")
end
puts "#{install_path}/index.html"
nb_generated += 1

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
    else
      size = size / 1024
      if size == 0 then
        "1 K"
      else
        parts = []
        while size != 0 do
          parts << (size < 1000 ? size.to_s : sprintf("%03d", size % 1000))
          size /= 1000
        end
        "#{parts.reverse.join(",")} K"
      end
    end
  end
end

# Generate the tables of results.
renderer = ERB.new(File.read("table.html.erb", encoding: "binary"))
for architecture in database.architectures do
  for repository in Database.repositories do
    folder_name = "#{install_path}/#{architecture}/#{repository}"
    FileUtils.mkdir_p(folder_name)
    file_name = "#{folder_name}/index.html"
    File.open(file_name, "w") do |file|
      file << renderer.result().gsub(/\n\s*\n/, "\n")
    end
    puts file_name
    nb_generated += 1
  end
end

# Generate the logs for each package.
for architecture in database.architectures do
  for repository in Database.repositories do
    for coq_version in database.coq_versions(architecture, repository) do
      for time in database.times(architecture, repository, coq_version) do
        results = database.in_memory[architecture][repository][coq_version][time]
        for name, results in results do
          for version, result in results do
            folder_name = "#{install_path}/#{architecture}/#{repository}/#{coq_version}/#{name}/#{version}"
            FileUtils.mkdir_p(folder_name)
            renderer = ERB.new(File.read("logs.html.erb", encoding: "binary"))
            file_name = "#{folder_name}/#{time.strftime("%F_%H-%M-%S")}.html"
            # Check if the file already exists.
            unless File.exists?(file_name) then
              File.open(file_name, "w") do |file|
                file << renderer.result().gsub(/\n\s*\n/, "\n")
              end
              puts file_name
              nb_generated += 1
            end
          end
        end
      end
    end
  end
end

puts "#{nb_generated} generated HTML files."
