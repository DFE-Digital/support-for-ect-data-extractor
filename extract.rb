require 'pg'
require 'pry'
require 'pry-byebug'
require_relative 'db'
require_relative 'programme'

# CURRENT STRUCTURE
#
# The tables form a hiearachy of learning materials:
#
# core_induction_programmes
#   course_years
#     course_modules
#       course_lessons
#         course_lesson_parts
#         mentor_materials
#           mentor_material_parts
#
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
#         ect: {
#           parts: []
#         },
#         mentor {
#           part: []
#         }
#       }
#     }
#   }
# }

$db = PG.connect(dbname: 'engage_and_learn')

core_induction_programmes = query("select * from core_induction_programmes;", %w(id name)).map do |cip|
  Programme.new(**cip)
end

puts core_induction_programmes.map(&:name)
