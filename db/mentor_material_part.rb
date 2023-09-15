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
end
