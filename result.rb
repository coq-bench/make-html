class Result
  def initialize(result)
    @status = result[0]
    @duration = result[1]
  end

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