class Year
  attr_reader :id, :title, :mentor_title, :core_induction_programme_id, :position
  attr_writer :content, :course_modules

  def initialize(id:, title:, content:, mentor_title:, core_induction_programme_id:, position:)
    @id = id
    @title = title
    @content = content
    @mentor_title = mentor_title
    @core_induction_programme_id = core_induction_programme_id
    @position = position
  end

  def self.all(sql: "select * from course_years;",
               projection: %w(id title content mentor_title core_induction_programme_id position))
    query(sql, projection).map { |cip| new(**cip) }
  end

  def to_s
    "  year: #{position}"
  end

  def year_name
    "Year #{position}"
  end

  def content
    <<~CONTENT
      #{content}
    CONTENT
  end

  def <=>(other)
    position <=> other.position
  end

  def course_modules
    return @course_modules if @course_modules.size == 1

    @course_modules.select { |cm| cm.previous_module_id.nil? }.tap do |out|
      loop do
        next_part = @course_modules.find { |cm| cm.previous_module_id == out.last.id }

        break if next_part.nil?

        out.append(next_part)
      end
    end
  end
end
