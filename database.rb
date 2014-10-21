# Read the CSV database of benchmarks.
require 'csv'
require 'fileutils'

class Database
  def initialize(folder)
    @folder = folder
  end

  def architectures
    Dir.glob("#{@folder}/*").map do |name|
      # We allow standard files at the root of the database (LICENSE, ...).
      if File.directory?(name) then
        File.basename(name)
      else
        nil
      end
    end.find_all {|x| ! x.nil?}.sort {|x, y| x[0] <=> y[0]}
  end

  def coq_versions(architecture)
    Dir.glob("#{@folder}/#{architecture}/*").map do |name|
      File.basename(name)
    end
  end

  def packages(architecture, coq_version, repository)
    (Dir.glob("#{@folder}/#{architecture}/#{coq_version}/#{repository}/*").map do |name|
      [File.basename(name),
        (Dir.glob("#{name}/*").map do |path|
          File.basename(path, ".csv")
        end).sort]
    end).sort {|x, y| x[0] <=> y[0]}
  end

  def read_history(architecture, coq_version, repository, name, version)
    file_name = "#{@folder}/#{architecture}/#{coq_version}/#{repository}/#{name}/#{version}.csv"
    rows = CSV.read(file_name).map do |row|
      [Time.at(row[0].to_i)] + row[1..-1]
    end
    rows.sort {|x, y| - (x[0] <=> y[0])}
  end
end