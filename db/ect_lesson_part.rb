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

  def title_with_dashes
    title.gsub(" ", "-").downcase
  end

  def filename(term, week_number, original: false)
    if week_number.positive?
      "#{term}-week-#{week_number}-ect-#{title_with_dashes}#{'.original' if original}.md"
    else
      "intro-#{title_with_dashes}#{'.original' if original}.md"
    end
  end
end
