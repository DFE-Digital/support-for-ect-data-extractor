class MentorMaterial
  attr_reader :id, :title, :course_lesson_id, :position, :completion_time_in_minutes
  attr_writer :mentor_material_parts

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

  def title_without_week
    # NOTE: we cannot use String#delete_prefix here because it doesn't support regepxs 😞

    title.gsub(/Week \d+: /, "").capitalize
  end

  def to_s
    "        mentor_material: #{id}"
  end

  def mentor_material_parts
    return @mentor_material_parts if @mentor_material_parts.size == 1

    @mentor_material_parts.select { |p| p.previous_mentor_material_part_id.nil? }.tap do |out|
      loop do
        next_part = @mentor_material_parts.find { |p| p.previous_mentor_material_part_id == out.last.id }

        break if next_part.nil?

        out.append(next_part)
      end
    end
  end

  def title_with_dashes
    title_without_week.gsub(" ", "-").gsub(":", "-").squeeze("-").downcase
  end

  def self.filename(term, week_number, with_extension: false)
    ext = with_extension ? ".md" : ""

    "#{term}-week-#{week_number}-mentor-materials#{ext}"
  end
end
