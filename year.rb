class Year
  attr_reader :id, :title, :content, :mentor_title, :core_induction_programme_id, :position
  attr_accessor :course_modules

  def initialize(id:, title:, content:, mentor_title:, core_induction_programme_id:, position:)
    @id = id
    @title = title
    @content = content
    @mentor_title = mentor_title
    @core_induction_programme_id = core_induction_programme_id
    @position = position
  end

  def self.all(sql: "select * from course_years;",
               projection: %w(id title content mentor_title core_induction_programme_id position))
    query(sql, projection).map { |cip| new(**cip) }
  end

  def to_s
    "  year: #{id}"
  end
end
