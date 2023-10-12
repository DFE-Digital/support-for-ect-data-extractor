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
  attr_writer :ect_lesson_parts, :mentor_materials

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
    @position = position.to_i
    @mentor_title = mentor_title
    @ect_teacher_standards = ect_teacher_standards
    @mentor_teacher_standards = mentor_teacher_standards
  end

  def week_number
    if (match = title.match(/Week (?<week>\d+)/))
      match["week"].to_i
    else
      0
    end
  end

  def self.all(sql: "select * from course_lessons;",
               projection: %w(id title previous_lesson_id course_module_id completion_time_in_minutes ect_summary
                              mentor_summary position mentor_title ect_teacher_standards mentor_teacher_standards))
    query(sql, projection).map { |l| new(**l) }
  end

  def to_s
    "      lesson: #{id}"
  end

  def ect_lesson_parts
    return @ect_lesson_parts if @ect_lesson_parts.size == 1

    @ect_lesson_parts.select { |p| p.previous_lesson_part_id.nil? }.tap do |out|
      loop do
        next_part = @ect_lesson_parts.find { |p| p.previous_lesson_part_id == out.last.id }

        break if next_part.nil?

        out.append(next_part)
      end
    end
  end

  def mentor_materials
    @mentor_materials.sort_by(&:position)
  end
end
