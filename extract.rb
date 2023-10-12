# frozen_string_literal: true

DEBUG = ENV.fetch('DEBUG', false)

require 'pg'
require 'fileutils'
require 'pry'
require 'pry-byebug'
require 'reverse_markdown'

require_relative 'db'
require_relative 'db/programme'
require_relative 'db/year'
require_relative 'db/course_module'
require_relative 'db/ect_lesson'
require_relative 'db/ect_lesson_part'
require_relative 'db/mentor_material'
require_relative 'db/mentor_material_part'
require_relative 'debug'
require_relative 'md/util'
require_relative 'md/formatter'

BLANK_LINE = "\n"

# the tables in the current serivice form a hiearachy of learning materials:
#
# core_induction_programmes
#   course_years
#     course_modules
#       course_lessons
#         course_lesson_parts
#         mentor_materials
#           mentor_material_parts
#
# In order to do any kind of transformation we'll need to pull the records
# out of the database:

$db = PG.connect(dbname: 'engage_and_learn')

programmes = Programme.all
years = Year.all
course_modules = CourseModule.all
ect_lessons = ECTLesson.all
ect_lesson_parts = ECTLessonPart.all
mentor_materials = MentorMaterial.all
mentor_material_parts = MentorMaterialPart.all

# we want to convert this into nested objects in the following structure
# so we can:
#
# * validate the extract is working correctly
# * clean and export the data into markdown files
#
# {
#   core_induction_programme: {
#     year: {
#       module: {
#         ect_lesson: {
#           ect_lesson_parts: [],
#           mentor_material {
#             mentor_lesson_parts: []
#           }
#         },
#       }
#     }
#   }
# }

puts "Reading content"

programmes.each do |p|
  p.years = years.select { |y| p.id == y.core_induction_programme_id }.each do |y|
    y.course_modules = course_modules.select { |cm| y.id == cm.course_year_id }.each do |cm|
      cm.ect_lessons = ect_lessons.select { |el| cm.id == el.course_module_id }.each do |el|
        el.ect_lesson_parts = ect_lesson_parts.select { |lp| el.id == lp.course_lesson_id }

        el.mentor_materials = mentor_materials.select { |mm| el.id == mm.course_lesson_id }.each do |mm|
          mm.mentor_material_parts = mentor_material_parts.select { |mmp| mm.id == mmp.mentor_material_id }
        end
      end
    end
  end
end

# puts DebugExport.new.print(programmes)

# now we have our data in a nice tree we can begin to loop
# through and write it to files.
#
# some fields are longform text in markdown format, we'll have
# to tidy them by:
#
# * replacing common HTML tags introduced by the editor with their
#   markdown equivalents, e.g., `<h3>Title</h3>` becomes `### Title`
# * replacing GovSpeak with GOV.UK Markdown syntax, e.g.,
#   `$Details...$EndDetails` become `{details}...{/details}`
#
#   other tags are:
#     - $Figure
#     - $YoutubeVideo
#
# * removing weird artefacts like `$I`
#
# other fields are longform text in HTML - we should try to convert
# those to markdown

puts "Generating output"

output_dir = 'output'

# we'll delete and recreate our output directory every time to
# keep things simple
FileUtils.rm_rf(File.join(output_dir)) if Dir.exist?(output_dir)
Dir.mkdir(output_dir)

# now to build the output 🔨
programmes.each do |p|
  # create a directory in output and a markdown file with the
  # same name:
  #
  # output
  # ├── some-programme/   🟢
  # └── some-programme.md 🟢
  Dir.mkdir(File.join(output_dir, p.name_with_dashes))
  File.open(p.filename(output_dir), "w") do |programme_file|
    # this file represents the programme's overview # and will
    # contain a listing of years, with each year having its
    # modules within
    programme_file.puts(frontmatter(title: p.name))

    p.years.sort.each do |y|
      programme_file.puts(h2(y.year_name))
      programme_file.puts(y.summary)
      programme_file.puts(BLANK_LINE)

      # sometimes there are two modules per term so we need to group by the
      # term and then loop through the modules within
      #
      # we want the terms to be in the academic year order, which is autumn,
      # spring, summer - thankfully this is also alphabetical order
      y.course_modules.group_by(&:term).sort.each do |term_name, modules_in_term|
        programme_file.puts(h3("#{term_name.capitalize} term"))

        modules_in_term.each do |cm|
          programme_file.puts(h4(cm.link(text: cm.title, year: y.position, path: p.name_with_dashes)))

          programme_file.puts(cm.ect_summary)
          programme_file.puts(BLANK_LINE)

          # if we haven't seen this year/module combo before create a directory
          # for its contents
          cm.directory_name(left: File.join(p.name_with_dashes), year: y.position).tap do |cm_dir|
            full_cm_dir = File.join(output_dir, cm_dir)
            # output
            # ├── some-programme
            # │  └── year-1-module-a 🟢
            # └── some-programme.md
            Dir.mkdir(full_cm_dir) unless Dir.exist?(full_cm_dir)
            File.open("#{full_cm_dir}.md", "w") do |cm_file|
              cm_file.puts(frontmatter(title: %(#{y.year_name}: #{cm.title}), heading: cm.title, caption: y.year_name))
              cm_file.puts(BLANK_LINE)
              cm_file.puts(cm.ect_summary)
              cm_file.puts(BLANK_LINE)

              # output
              # ├── some-programme
              # │  ├── year-1-module-a
              # │  └── year-1-module-a.md 🟢
              # └── some-programme.md
              cm.ect_lessons.each do |l|
                cm_file.puts(h2(l.title))

                cm_file.puts(h3("ECT summary"))
                cm_file.puts(l.ect_summary)

                cm_file.puts(BLANK_LINE)
                cm_file.puts(h4("Lessons"))
                l.ect_lesson_parts.each.with_index(1) do |lp, i|
                  File.join('/', cm_dir, lp.filename(term_name, l.week_number, with_extension: false)).tap do |link|
                    cm_file.puts(%{#{i}. [#{lp.title}](#{link})})
                  end
                end
                cm_file.puts(BLANK_LINE)

                cm_file.puts(h3("Mentor summary"))
                cm_file.puts(l.mentor_summary)
                cm_file.puts(BLANK_LINE)

                File.join('/', cm_dir, MentorMaterial.filename(term_name, l.week_number)).tap do |link|
                  cm_file.puts("[View mentor materials](#{link})")
                end

                cm_file.puts(BLANK_LINE)
              end
            end

            cm.ect_lessons.each do |l|
              # within the directory we will create a file per lesson part, prefixed
              # with the year number, like `week-3-self-study-activities.md
              # output
              # ├── some-programme
              # │  └── year-1-module-a
              # │     ├── autumn-week-1-ect-module-overview.md                 🟢
              # │     ├── autumn-week-1-ect-reflect.md                         🟢
              # │     └── autumn-week-1-ect-video-and-module-introduction.md   🟢
              # └── some-programme.md
              l.ect_lesson_parts.each do |lp|
                # each lesson part has a pagination 'next' and 'previous' link
                # if there is preceeding or succeeding lesson. we'll set these
                # using frontmatter values next_title, next_path, previous_title,
                # and previous_path.
                #
                # we'll build hashes here and splat them in below
                prev_fm = if (prev_lp = lp.previous_part(l.ect_lesson_parts))
                            {
                              previous_title: prev_lp.title,
                              previous_path: File.join("/", cm_dir, prev_lp.filename(term_name, l.week_number, with_extension: false))
                            }
                          else
                            {}
                          end
                next_fm = if (next_lp = lp.next_part(l.ect_lesson_parts))
                            {
                              next_title: next_lp.title,
                              next_path: File.join("/", cm_dir, next_lp.filename(term_name, l.week_number, with_extension: false))
                            }
                          else
                            {}
                          end

                File.open(File.join(full_cm_dir, lp.filename(term_name, l.week_number)), "w") do |lesson_part_file|
                  lesson_part_file.puts(
                    frontmatter(
                      title: lp.title,
                      total_lesson_completion_time: l.completion_time_in_minutes,
                      **prev_fm,
                      **next_fm
                    )
                  )
                  lesson_part_file.puts(Formatter.new(lp.content).tidy)
                end

                next unless DEBUG

                # output
                # ├── some-programme
                # │  └── year-1-module-a
                # │     ├── autumn-week-1-ect-module-overview.md
                # │     ├── autumn-week-1-ect-module-overview.original.md                 🟢
                # │     ├── autumn-week-1-ect-reflect.md
                # │     ├── autumn-week-1-ect-reflect.original.md                         🟢
                # │     ├── autumn-week-1-ect-video-and-module-introduction.md
                # │     └── autumn-week-1-ect-video-and-module-introduction.original.md   🟢
                # └── some-programme.md
                File.open(File.join(full_cm_dir, lp.filename(term_name, l.week_number, original: true)), "w") do |lesson_part_file|
                  lesson_part_file.puts(lp.content)
                end
              end

              # output
              # ├── ambition-institute
              # │  └── year-1-module-a
              # │     └── autumn-week-1-mentor-materials.md 🟢
              # └── some-programme.md
              mm_filename = MentorMaterial.filename(term_name, l.week_number, with_extension: true)
              File.open(File.join(full_cm_dir, mm_filename), "w") do |mentor_material_file|
                mentor_material_file.puts(
                  frontmatter(
                    title: "#{y.year_name} #{term_name.capitalize} week #{l.week_number} mentor materials",
                    heading: "Mentor materials",
                    caption: "#{term_name.capitalize} week #{l.week_number}"
                  )
                )

                mentor_material_file.puts(BLANK_LINE)

                l.mentor_materials.each do |mm|
                  # occasionally a lesson has more than one mentor material
                  mentor_material_file.puts(h2(mm.title_without_week))

                  mm.mentor_material_parts.each do |mmp|
                    mentor_material_file.puts(h3(mmp.title))
                    mentor_material_file.puts(Formatter.new(mmp.content).tidy)
                    mentor_material_file.puts(BLANK_LINE)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
