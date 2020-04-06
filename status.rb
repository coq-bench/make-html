# encoding: utf-8
# The status of a bench.
require_relative 'black_list'

class Status
  attr_reader :status

  def initialize(name, version, status, dry_without_coq_output, deps_output, package_output)
    black_listed = BlackList.any? do |black_list_item|
      package_full_name, content = black_list_item
      if package_full_name == "#{name}.#{version}" then
        [dry_without_coq_output, deps_output, package_output].any? do |output|
          output.include?(content)
        end
      else
        false
      end
    end
    download_error_message = "[ERROR] The sources of the following couldn't be obtained, aborting:"
    with_download_error = [deps_output, package_output].any? do |output|
      output.include?(download_error_message)
    end
    @status = black_listed || with_download_error ? "BlackList" : status
  end

  # The color to display.
  def css_class
    case @status
    when "Success"
      "success"
    when "NotCompatible"
      "info"
    when "DepsError"
      "warning"
    when "LintError", "Error", "UninstallError"
      "danger"
    when "BlackList"
      "default"
    else
      raise "unknown status #{@status.inspect}"
    end
  end

  # A number to classify and order a status.
  def to_i
    case @status
    when "NotCompatible"
      4
    when "BlackList"
      3
    when "Success"
      2
    when "DepsError"
      1
    when "LintError", "Error", "UninstallError"
      0
    else
      raise "unknown status #{@status}"
    end
  end

  # A unicode symbol representing the error status.
  def unicode_error_symbol
    case @status
    when "DepsError"
      "🔶"
    when "LintError", "Error", "UninstallError"
      "❌"
    when "NotCompatible", "Success", "BlackList"
      nil
    else
      raise "unknown status #{@status}"
    end
  end
end
