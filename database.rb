# Read the CSV database of benchmarks.
require 'csv'
require 'fileutils'
require 'time'
require_relative 'result'

class Database
  def Database.repositories
    ["stable", "testing", "unstable"]
  end

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
    Dir.glob("#{@folder}/#{architecture}/#{repository}/*").map do |name|
      File.basename(name)
    end.sort {|x, y| compare_versions(x, y)}
  end

  def times(architecture, repository, coq_version)
    Dir.glob("#{@folder}/#{architecture}/#{repository}/#{coq_version}/*.csv").map do |name|
      Time.strptime(File.basename(name, ".csv"), "%F_%T")
    end.sort.reverse
  end

  def packages(architecture, repository, coq_version, time)
    file_name = "#{@folder}/#{architecture}/#{repository}/#{coq_version}/#{time.strftime("%F_%T")}.csv"
    CSV.read(file_name).map do |row|
      [row[0], row[1], Result.new(row[2..-1])]
    end.sort
  end

  def repository_packages(architecture, repository)
    coq_versions(architecture, repository).map do |coq_version|
      time = times(architecture, repository, coq_version)[0]
      packages(architecture, repository, coq_version, time)
    end
  end


  # def packages(architecture, repository, coq_version)
  #   (Dir.glob("#{@folder}/#{architecture}/#{repository}/#{coq_version}/*").map do |name|
  #     [File.basename(name),
  #       (Dir.glob("#{name}/*").map do |path|
  #         File.basename(path, ".csv")
  #       end).sort {|x, y| compare_versions(x, y)}]
  #   end).sort {|x, y| x[0] <=> y[0]}
  # end

  # def read_history(architecture, coq_version, repository, name, version)
  #   file_name = "#{@folder}/#{architecture}/#{coq_version}/#{repository}/#{name}/#{version}.csv"
  #   rows = CSV.read(file_name).map do |row|
  #     [Time.at(row[0].to_i)] + row[1..-1]
  #   end
  #   rows.sort {|x, y| - (x[0] <=> y[0])}
  # end

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