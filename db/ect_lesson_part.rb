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
    title.gsub(" ", "-").downcase.squeeze("-")
  end

  def filename(term, week_number, original: false, with_extension: true)
    ext = with_extension ? ".md" : nil

    if week_number.positive?
      "#{term}-week-#{week_number}-ect-#{title_with_dashes}#{'.original' if original}#{ext}"
    else
      "intro-ect-#{title_with_dashes}#{'.original' if original}#{ext}"
    end
  end

  def previous_part(others)
    others.detect { |other| other.id == previous_lesson_part_id }
  end

  def next_part(others)
    others.detect { |other| other.previous_lesson_part_id == id }
  end
end
