require_relative 'status'

# The result of a bench.
class Result
  attr_reader :status, :context,
    :lint_command, :lint_status, :lint_duration, :lint_output,
    :dry_with_coq_command, :dry_with_coq_status, :dry_with_coq_duration, :dry_with_coq_output,
    :dry_without_coq_command, :dry_without_coq_status, :dry_without_coq_duration, :dry_without_coq_output,
    :deps_command, :deps_status, :deps_duration, :deps_output,
    :package_command, :package_status, :package_duration, :package_output,
    :uninstall_command, :uninstall_status, :uninstall_duration, :uninstall_output,
    :missing_removes, :mistake_removes, :install_sizes

  def initialize(*arguments)
    name, version, status, @context,
      @lint_command, @lint_status, @lint_duration, @lint_output,
      @dry_with_coq_command, @dry_with_coq_status, @dry_with_coq_duration, @dry_with_coq_output,
      @dry_without_coq_command, @dry_without_coq_status, @dry_without_coq_duration, @dry_without_coq_output,
      @deps_command, @deps_status, @deps_duration, @deps_output,
      @package_command, @package_status, @package_duration, @package_output,
      @uninstall_command, @uninstall_status, @uninstall_duration, @uninstall_output,
      @missing_removes, @mistake_removes, @install_sizes =
      arguments
    @status = Status.new(name, version, status, @dry_without_coq_output, @deps_output, @package_output)
    @missing_removes = @missing_removes.split("\n")
    @mistake_removes = @mistake_removes.split("\n")
    @install_sizes &&= @install_sizes.split("\n").each_slice(2).to_a
  end

  # A short message for the status.
  def short_message
    case @status.status
    when "Success"
      @package_duration.to_i.duration
    when "NotCompatible"
      "NC"
    when "BlackList"
      "BL"
    when "LintError"
      "Lint"
    when "DepsError"
      "Deps"
    when "Error"
      "Error"
    when "UninstallError"
      "Uninstall"
    else
      raise "unknown status #{@status.inspect}"
    end
  end

  # A long message for the status.
  def long_message
    case @status.status
    when "Success"
      @package_duration.to_i.duration + " 🏆"
    when "NotCompatible"
      "Not compatible 👼"
    when "BlackList"
      "Black list 🏴‍☠️"
    when "LintError"
      "Lint error 💥"
    when "DepsError"
      "Error with dependencies 🚒"
    when "Error"
      "Error 🔥"
    when "UninstallError"
      "Uninstallation error 🌪️"
    else
      raise "unknown status #{@status}"
    end
  end
end
