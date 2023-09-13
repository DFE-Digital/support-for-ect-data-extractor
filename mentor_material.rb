class MentorMaterial
  attr_reader :id, :title, :course_lesson_id, :position, :completion_time_in_minutes
  attr_accessor :mentor_material_parts

  def initialize(id:, title:, course_lesson_id:, position:, completion_time_in_minutes:)
    @id = id
    @title = title
    @course_lesson_id = course_lesson_id
    @position = position
    @completion_time_in_minutes = completion_time_in_minutes
  end

  def self.all(sql: "select * from mentor_materials;",
               projection: %w(id title course_lesson_id position completion_time_in_minutes))
    query(sql, projection).map { |ml| new(**ml) }
  end

  def to_s
    "        mentor_material: #{id}"
  end
end
