# The result of a bench.
class Result
  attr_reader :status,
    :dry_with_coq_command, :dry_with_coq_status, :dry_with_coq_duration, :dry_with_coq_output,
    :dry_without_coq_command, :dry_without_coq_status, :dry_without_coq_duration, :dry_without_coq_output,
    :deps_command, :deps_status, :deps_duration, :deps_output,
    :package_command, :package_status, :package_duration, :package_output

  def initialize(*arguments)
    @status,
      @dry_with_coq_command, @dry_with_coq_status, @dry_with_coq_duration, @dry_with_coq_output,
      @dry_without_coq_command, @dry_without_coq_status, @dry_without_coq_duration, @dry_without_coq_output,
      @deps_command, @deps_status, @deps_duration, @deps_output,
      @package_command, @package_status, @package_duration, @package_output =
      arguments
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
    when "Error"
      "danger"
    else
      raise "unknown status #{@status.inspect}"
    end
  end

  # A short message for the status.
  def short_message
    case @status
    when "Success"
      @package_duration.to_i.duration
    when "NotCompatible"
      "OK"
    when "DepsError", "Error"
      "Error"
    else
      raise "unknown status #{@status.inspect}"
    end
  end

  # A long message for the status.
  def long_message
    case @status
    when "Success"
      @package_duration.to_i.duration
    when "NotCompatible"
      "Not compatible with this Coq"
    when "DepsError"
      "Error with dependencies"
    when "Error"
      "Error"
    else
      raise "unknown status #{@status}"
    end
  end
end