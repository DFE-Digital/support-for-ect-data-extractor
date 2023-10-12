class MentorMaterialPart
  attr_accessor :id, :title, :content, :previous_mentor_material_part_id, :mentor_material_id

  def initialize(id:, title:, content:, previous_mentor_material_part_id:, mentor_material_id:)
    @id = id
    @title = title
    @content = content
    @previous_mentor_material_part_id = previous_mentor_material_part_id
    @mentor_material_id = mentor_material_id
  end

  def self.all(sql: "select * from mentor_material_parts;",
               projection: %w(id title content previous_mentor_material_part_id mentor_material_id))
    query(sql, projection).map { |mlp| new(**mlp) }
  end

  def to_s
    "          mentor_material_part: #{id}"
  end

  def title_with_dashes
    title.gsub(%r{\s|/}, "-").downcase.squeeze("-")
  end

  def filename(term, week_number, original: false, with_extension: true)
    ext = with_extension ? ".md" : nil

    if week_number.positive?
      "#{term}-week-#{week_number}-mentor-#{title_with_dashes}#{'.original' if original}#{ext}"
    else
      "intro-mentor-#{title_with_dashes}#{'.original' if original}.md"
    end
  end

  def previous_part(others)
    others.detect { |other| other.id == previous_mentor_material_part_id }
  end

  def next_part(others)
    others.detect { |other| other.previous_mentor_material_part_id == id }
  end
end
