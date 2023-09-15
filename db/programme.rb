class Programme
  attr_reader :id, :name
  attr_accessor :years

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def self.all(sql: "select * from core_induction_programmes;", projection: %w(id name))
    query(sql, projection).map { |cip| new(**cip) }
  end

  def to_s
    "  year: #{id}"
  end

  def name_with_dashes
    @name.downcase.tr(" ", "-")
  end

  def filename(output_dir)
    File.join(output_dir, "#{name_with_dashes}.md")
  end
end
