# Generate an HTML website in `html/` from the database in `database/`.
require 'erb'
require 'fileutils'
require_relative 'database'

FileUtils.mkdir_p("html")

# Copy the CSS and JavaScript.
FileUtils.cp(["bootstrap.min.css", "bootstrap.min.js", "favicon.png"], "html/")

# Prepare ERB.
include(ERB::Util)

# Prepare the database.
database = Database.new("database")

# Generate the index.
renderer = ERB.new(File.read("index.html.erb", :encoding => "UTF-8"))
File.open("html/index.html", "w") do |file|
  file << renderer.result().gsub(/\n\s*\n/, "\n")
end
puts "html/index.html"

exit

def css_class_of_bench(bench)
  case bench[1]
  when "Success"
    "success"
  when "NotCompatible"
    "info"
  when "DepsError"
    "warning"
  when "Error"
    "danger"
  else
    raise "unknown status #{bench[1]}"
  end
end

# Generate the tables of results.
renderer = ERB.new(File.read("table.html.erb", :encoding => "UTF-8"))
for architecture in database.architectures do
  for coq_version in database.coq_versions(architecture) do
    folder_name = "html/#{architecture}/#{coq_version}"
    FileUtils.mkdir_p(folder_name)
    file_name = "#{folder_name}/index.html"
    File.open(file_name, "w") do |file|
      file << renderer.result().gsub(/\n\s*\n/, "\n")
    end
    puts file_name
  end
end

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
end

# Generate the history for each package.
for architecture in database.architectures do
  for coq_version in database.coq_versions(architecture) do
    for repository in [:stable, :testing, :unstable] do
      for name, versions in database.packages(architecture, coq_version, repository) do
        folder_name = "html/#{architecture}/#{coq_version}/#{repository}/#{name}"
        FileUtils.mkdir_p(folder_name)
        for version in versions do
          renderer = ERB.new(File.read("package.html.erb", :encoding => "UTF-8"))
          file_name = "#{folder_name}/#{version}.html"
          File.open(file_name, "w") do |file|
            file << renderer.result().gsub(/\n\s*\n/, "\n")
          end
          puts file_name
        end
      end
    end
  end
end