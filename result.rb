# The result of a bench.
class Result
  def initialize(result)
    @status = result[0]
    @duration = result[1]
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
      raise "unknown status #{@status}"
    end
  end

  # The message to diplay in the table.
  def table_message
    case @status
    when "Success"
      @duration.to_i.duration
    when "NotCompatible"
      "OK"
    when "DepsError", "Error"
      "Error"
    else
      raise "unknown status #{@status}"
    end
  end
end