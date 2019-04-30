# The status of a bench.
class Status
  attr_reader :status

  def initialize(status)
    @status = status
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
    else
      raise "unknown status #{@status.inspect}"
    end
  end

  # A number to classify and order a status.
  def to_i
    case @status
    when "NotCompatible"
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
end
