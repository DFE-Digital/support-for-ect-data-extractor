class ECTLesson
  attr_reader :id,
              :title,
              :previous_lesson_id,
              :course_module_id,
              :completion_time_in_minutes,
              :ect_summary,
              :mentor_summary,
              :position,
              :mentor_title,
              :ect_teacher_standards,
              :mentor_teacher_standards
  attr_accessor :ect_lesson_parts, :mentor_materials

  def initialize(
    id:,
    title:,
    previous_lesson_id:,
    course_module_id:,
    completion_time_in_minutes:,
    ect_summary:,
    mentor_summary:,
    position:,
    mentor_title:,
    ect_teacher_standards:,
    mentor_teacher_standards:
  )
    @id = id
    @title = title
    @previous_lesson_id = previous_lesson_id
    @course_module_id = course_module_id
    @completion_time_in_minutes = completion_time_in_minutes
    @ect_summary = ect_summary
    @mentor_summary = mentor_summary
    @position = position
    @mentor_title = mentor_title
    @ect_teacher_standards = ect_teacher_standards
    @mentor_teacher_standards = mentor_teacher_standards
  end

  def self.all(sql: "select * from course_lessons;",
               projection: %w(id title previous_lesson_id course_module_id completion_time_in_minutes ect_summary
                              mentor_summary position mentor_title ect_teacher_standards mentor_teacher_standards))
    query(sql, projection).map { |l| new(**l) }
  end

  def to_s
    "      lesson: #{id}"
  end
end
