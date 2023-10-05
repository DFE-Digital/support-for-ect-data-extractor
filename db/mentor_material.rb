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
    @sorted_mentor_material_parts = @mentor_material_parts.each_with_object([]) do |p, a|
      # if there's no previous entry it must be the first, so prepend it
      if p.previous_mentor_material_part_id.nil?
        a.prepend(p)
      # if the previous id already exists, this comes immediately after it
      elsif (index = a.index { |e| e.id == p.previous_mentor_material_part_id })
        a.insert(index + 1, p)
      # we haven't seen the previous one yet, so add it on the end
      else
        a.append(p)
      end
    end
  end

  def title_with_dashes
    title.gsub(" ", "-").downcase
  end

  def filename(term, week_number, original: false, with_extension: false)
    ext = with_extension ? ".md" : nil

    if week_number.positive?
      "#{term}-week-#{week_number}-mentor-#{title_with_dashes}#{'.original' if original}#{ext}"
    else
      "intro-mentor-#{title_with_dashes}#{'.original' if original}#{ext}"
    end
  end
end
