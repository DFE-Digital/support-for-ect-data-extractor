require 'pg'
require 'pry'
require 'pry-byebug'

require_relative 'db'
require_relative 'db/programme'
require_relative 'db/year'
require_relative 'db/course_module'
require_relative 'db/ect_lesson'
require_relative 'db/ect_lesson_part'
require_relative 'db/mentor_material'
require_relative 'db/mentor_material_part'
require_relative 'debug'

# The tables in the current serivice form a hiearachy of learning materials:
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

core_induction_programmes = Programme.all
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

core_induction_programmes.each do |cip|
  cip.years = years.select { |y| cip.id == y.core_induction_programme_id }.each do |y|
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

puts Debug.new.print(core_induction_programmes)
