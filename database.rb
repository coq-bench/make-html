# Read the CSV database of benchmarks.
require 'csv'
require 'fileutils'
require 'time'
require_relative 'result'

class Database
  attr_reader :in_memory

  # The names of expected repositories.
  def Database.repositories
    ["released", "extra-dev"]
  end

  def initialize(folder)
    # {architecture => repository => coq_version =>
    #   {time: time, results: {name => version => result}}}
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
            regexp = "#{folder}/#{architecture}/#{repository}/#{coq_version}/*.csv"
            def time(file_name)
              Time.strptime(File.basename(file_name, ".csv"), "%F_%T")
            end
            file_name = Dir.glob(regexp).max_by {|file_name| time(file_name)}
            # TODO: check if file_name is empty
            @in_memory[architecture][repository][coq_version] = {
              time: time(file_name),
              results: {}}
            CSV.read(file_name, encoding: "binary")[1..-1].map do |row|
              name = row[0][4..-1]
              @in_memory[architecture][repository][coq_version][:results][name] ||= {}
              version = row[1]
              result = Result.new(*row[2..-1])
              @in_memory[architecture][repository][coq_version][:results][name][version] = result
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

  # The more recent bench for an architecture.
  def last_bench(architecture, repository)
    last = @in_memory[architecture][repository].max_by {|_, results| results[:time]}
    if last then
      last[1][:time]
    else
      nil
    end
  end

  # The Coq versions tested for a given architecture and repository.
  def coq_versions(architecture, repository)
    @in_memory[architecture][repository].keys.sort {|x, y| compare_versions(x, y)}
  end

  # {name => version => coq_version => result}
  def packages_hash(architecture, repository)
    output = {}
    for coq_version in coq_versions(architecture, repository) do
      for name, results in @in_memory[architecture][repository][coq_version][:results] do
        output[name] ||= {}
        for version, result in results do
          output[name][version] ||= {}
          output[name][version][coq_version] = result
        end
      end
    end
    output
  end

  # The number of packages for an architecture and repository, using the minimum
  # of number of packages for the last bench of each Coq version.
  def number_of_packages(architecture, repository)
    n_min = nil
    for coq_version in coq_versions(architecture, repository) do
      n = 0
      for _, results in @in_memory[architecture][repository][coq_version][:results] do
        n += results.size
      end
      n_min = n_min ? [n_min, n].min : n
    end
    n_min ? n_min : 0
  end

  # The numbers of incompatibilities, errors, dependencies errors and successes,
  # in this order.
  def stats(architecture, repository, coq_version)
    output = [0, 0, 0, 0]
    for name, results in @in_memory[architecture][repository][coq_version][:results] do
      for version, result in results do
        output[result.status.to_i] += 1
      end
    end
    output
  end

  # Like `stats`, with the worst results for all coq versions.
  def worst_stats(architecture, repository)
    output = [0, 0, 0, 0]
    for _, results in packages_hash(architecture, repository) do
      for _, results in results do
        worst = 0
        for coq_version in coq_versions(architecture, repository) do
          if result = results[coq_version] then
            worst = [worst, result.status.to_i].max
          end
        end
        output[worst] += 1
      end
    end
    output
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
