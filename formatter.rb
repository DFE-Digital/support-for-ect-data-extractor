class Formatter
  def initialize(str)
    @str = str
  end

  def tidy
    @str
      .delete("\r")
      .gsub(/\s+\Z/, "")
  end
end
