class ECTLessonPart
  attr_reader :id, :title, :content, :previous_lesson_part_id, :course_lesson_id

  def initialize(id:, title:, content:, previous_lesson_part_id:, course_lesson_id:)
    @id = id
    @title = title
    @content = content
    @previous_lesson_part_id = previous_lesson_part_id
    @course_lesson_id = course_lesson_id
  end

  def self.all(sql: "select * from course_lesson_parts;",
               projection: %w(id title content previous_lesson_part_id course_lesson_id))
    query(sql, projection).map { |l| new(**l) }
  end

  def to_s
    "        lesson_part: #{id}"
  end
end
