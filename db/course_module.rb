class CourseModule
  attr_reader :id, :title, :previous_module_id, :course_year_id, :term, :mentor_summary, :page_header
  attr_accessor :ect_lessons

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

  def term_name
    "#{term.capitalize} term"
  end

  def ect_summary
    Formatter.new(@ect_summary).tidy
  end

  def directory_name(year:, left: "")
    right = "year-%<year>d-%<title>s" % {
      year: year,
      title: title_with_dashes
    }

    File.join(left, right)
  end

  def title_with_dashes
    title.gsub(/(First|Second) half-term: /, "")
         .gsub(/[^0-9a-z ]/i, "")
         .gsub(" ", "-")
         .downcase
  end

  def link(year:, path:, text: title)
    "[%<text>s](/%<link>s)" % { text: text, link: directory_name(left: path, year: year) }
  end
end
