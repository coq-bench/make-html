# Read the CSV database of benchmarks
require 'csv'
require 'fileutils'

class Database
  def initialize(folder)
    @folder = folder
  end

  def architectures
    Dir.glob("#{@folder}/*").map do |name|
      if File.directory?(name) then
        File.basename(name)
        # os, machine, ocaml, opam = name.split("-")
        # { os: os, machine: machine, ocaml: ocaml, opam: opam }
      else
        nil
      end
    end.find_all {|x| ! x.nil?}.sort {|x, y| x[0] <=> y[0]}
  end

  # def packages
  #   (Dir.glob("#{@folder}/*").map do |name|
  #     if File.directory?(name) then
  #       [File.basename(name),
  #         (Dir.glob("#{name}/*").map do |path|
  #           File.basename(path, ".csv")
  #         end).sort]
  #     else
  #       nil
  #     end
  #   end).find_all {|x| ! x.nil?}.sort {|x, y| x[0] <=> y[0]}
  # end

  # def read_history(name, version)
  #   rows = CSV.read(file_name(name, version)).map do |date, duration, status|
  #     [Time.at(date.to_i), duration.to_i, status]
  #   end
  #   rows.sort {|x, y| - (x[0] <=> y[0])}
  # end

private
  def file_name(folder, repository, architecture, coq, version)
    "#{@folder}/#{@repository}/#{@architecture}/#{@coq}/#{name}/#{version}.csv"
  end
end