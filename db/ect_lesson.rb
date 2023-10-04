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
  attr_writer :ect_lesson_parts
  attr_accessor :mentor_materials

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
    @ect_lesson_parts.each_with_object([]) do |p, a|
      # if there's no previous entry it must be the first, so prepend it
      if p.previous_lesson_part_id.nil?
        a.prepend(p)
      # if the previous id already exists, this comes immediately after it
      elsif (index = a.index { |e| e.id == p.previous_lesson_part_id })
        a.insert(index + 1, p)
      # we haven't seen the previous one yet, so add it on the end
      else
        a.append(p)
      end
    end
  end
end
