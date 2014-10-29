# Read the CSV database of benchmarks.
require 'csv'
require 'fileutils'
require 'time'
require_relative 'result'

class Database
  # The names of expected repositories.
  def Database.repositories
    ["stable", "testing", "unstable"]
  end

  def initialize(folder)
    @folder = folder
  end

  # The architectures present in the database.
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

  # The Coq versions tested for a given architecture and repository.
  def coq_versions(architecture, repository)
    Dir.glob("#{@folder}/#{architecture}/#{repository}/*").map do |name|
      File.basename(name)
    end.sort {|x, y| compare_versions(x, y)}
  end

  # The times of the benches for a given architecture, repository and Coq
  # version. At least one time is returned, or an error is raised.
  def times(architecture, repository, coq_version)
    regexp = "#{@folder}/#{architecture}/#{repository}/#{coq_version}/*.csv"
    output = Dir.glob(regexp).map do |name|
      Time.strptime(File.basename(name, ".csv"), "%F_%T")
    end.sort.reverse
    if output == [] then
      raise "At least on bench expected in #{regexp}."
    else
      output
    end
  end

  # The list of tested packages in a bench. A bench is described by an
  # architecture, a repository, a Coq version and a time. The output is an array
  # of `[name, version, result]`.
  def packages(architecture, repository, coq_version, time)
    file_name = "#{@folder}/#{architecture}/#{repository}/#{coq_version}/#{time.strftime("%F_%T")}.csv"
    CSV.read(file_name).map do |row|
      [row[0][4..-1], row[1], Result.new(*row[2..-1])]
    end.sort
  end

  # `{name => {version => {coq_version => result}}}`
  def packages_hash(architecture, repository)
    output = {}
    for coq_version in coq_versions(architecture, repository) do
      time = times(architecture, repository, coq_version)[0]
      packages = packages(architecture, repository, coq_version, time)
      for name, version, result in packages do
        output[name] = {} if output[name].nil?
        output[name][version] = {} if output[name][version].nil?
        output[name][version][coq_version] = result
      end
    end
    output
  end

  # `{time => result}`
  def history(architecture, repository, coq_version, name, version)
    history = {}
    for time in times(architecture, repository, coq_version) do
      packages = packages(architecture, repository, coq_version, time)
      for name2, version2, result in packages do
        if name == name2 && version == version2 then
          history[time] = result
        end
      end
    end
    history
  end

private
  # Compare two version numbers using the dpkg algorithm (the Debian package
  # manager). Needs a Debian-based distribution.
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