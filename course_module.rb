class CourseModule
  attr_reader :id, :title, :ect_summary, :previous_module_id, :course_year_id, :term, :mentor_summary, :page_header

  def initialize(id:, title:, ect_summary:, previous_module_id:, course_year_id:, term:, mentor_summary:, page_header:)
    @id = id
    @title = title
    @ect_summary = ect_summary
    @previous_module_id = previous_module_id
    @course_year_id = course_year_id
    @term = term
    @mentor_summary = mentor_summary
    @page_header = page_header
  end

  def self.all(sql: "select * from course_modules;",
               projection: %w(id title ect_summary previous_module_id course_year_id term mentor_summary page_header))
    query(sql, projection).map { |cm| new(**cm) }
  end

  def to_s
    "    course_module: #{id}"
  end
end
