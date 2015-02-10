# Read the CSV database of benchmarks.
require 'csv'
require 'fileutils'
require 'time'
require_relative 'result'

class Database
  attr_reader :in_memory

  # The names of expected repositories.
  def Database.repositories
    ["stable", "unstable"]
  end

  def initialize(folder)
    # `{architecture => repository => coq_version => time => name => version =>
    #   result}`.
    @in_memory = {}
    Dir.glob("#{folder}/*").map do |name|
      # We allow standard files at the root of the database (LICENSE, ...).
      if File.directory?(name) then
        architecture = File.basename(name)
        @in_memory[architecture] ||= {}
        for repository in Database.repositories do
          @in_memory[architecture][repository] ||= {}
          Dir.glob("#{folder}/#{architecture}/#{repository}/*").map do |name|
            coq_version = File.basename(name)
            @in_memory[architecture][repository][coq_version] ||= {}
            regexp = "#{folder}/#{architecture}/#{repository}/#{coq_version}/*.csv"
            Dir.glob(regexp).map do |file_name|
              time = Time.strptime(File.basename(file_name, ".csv"), "%F_%T")
              @in_memory[architecture][repository][coq_version][time] ||= {}
              CSV.read(file_name, encoding: "binary")[1..-1].map do |row|
                name = row[0][4..-1]
                @in_memory[architecture][repository][coq_version][time][name] ||= {}
                version = row[1]
                result = Result.new(*row[2..-1])
                @in_memory[architecture][repository][coq_version][time][name][version] = result
              end
            end
          end
        end
      end
    end
  end

  # The architectures present in the database.
  def architectures
    @in_memory.keys.sort
  end

  # The Coq versions tested for a given architecture and repository.
  def coq_versions(architecture, repository)
    @in_memory[architecture][repository].keys.sort {|x, y| compare_versions(x, y)}
  end

  # The times of the benches for a given architecture, repository and Coq
  # version. At least one time is returned, or an error is raised.
  def times(architecture, repository, coq_version)
    output = @in_memory[architecture][repository][coq_version].keys
    if output == [] then
      raise "At least one time expected for #{architecture}/#{repository}/#{coq_version}."
    else
      output.sort.reverse
    end
  end

  # `{name => {version => {coq_version => result}}}`.
  def packages_hash(architecture, repository)
    output = {}
    for coq_version in coq_versions(architecture, repository) do
      time = times(architecture, repository, coq_version)[0]
      for name, results in @in_memory[architecture][repository][coq_version][time] do
        output[name] ||= {}
        for version, result in results do
          output[name][version] ||= {}
          output[name][version][coq_version] = result
        end
      end
    end
    output
  end

  # The numbers of incompatibilities, errors, dependencies errors and successes,
  # in this order.
  def stats(architecture, repository, coq_version)
    output = [0, 0, 0, 0]
    time = times(architecture, repository, coq_version)[0]
    for name, results in @in_memory[architecture][repository][coq_version][time] do
      for version, result in results do
        output[result.status.to_i] += 1
      end
    end
    output
  end

  # Like `stats`, with the best results for all coq versions.
  def best_stats(architecture, repository)
    output = [0, 0, 0, 0]
    for _, results in packages_hash(architecture, repository) do
      for _, results in results do
        best = 0
        for coq_version in coq_versions(architecture, repository) do
          if result = results[coq_version] then
            best = [best, result.status.to_i].max
          end
        end
        output[best] += 1
      end
    end
    output
  end

  # `{time => result}`.
  def history(architecture, repository, coq_version, name, version)
    history = {}
    for time in times(architecture, repository, coq_version) do
      results = @in_memory[architecture][repository][coq_version][time]
      if results[name] && results[name][version] then
        history[time] = results[name][version]
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
