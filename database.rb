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

  def coq_versions(architecture, repository)
    Dir.glob("#{@folder}/#{architecture}/#{repository}*").map do |name|
      File.basename(name)
    end.sort {|x, y| compare_versions(x, y)}
  end

  def packages(architecture, coq_version, repository)
    (Dir.glob("#{@folder}/#{architecture}/#{coq_version}/#{repository}/*").map do |name|
      [File.basename(name),
        (Dir.glob("#{name}/*").map do |path|
          File.basename(path, ".csv")
        end).sort {|x, y| compare_versions(x, y)}]
    end).sort {|x, y| x[0] <=> y[0]}
  end

  def read_history(architecture, coq_version, repository, name, version)
    file_name = "#{@folder}/#{architecture}/#{coq_version}/#{repository}/#{name}/#{version}.csv"
    rows = CSV.read(file_name).map do |row|
      [Time.at(row[0].to_i)] + row[1..-1]
    end
    rows.sort {|x, y| - (x[0] <=> y[0])}
  end

private
  def compare_versions(x, y)
    if x == y then
      0
    # We use `dpkg` to compare two versions numbers according to the OPAM policy.
    elsif system("dpkg --compare-versions #{x} lt #{y} 2>/dev/null")
      -1
    else
      +1
    end
  end
end