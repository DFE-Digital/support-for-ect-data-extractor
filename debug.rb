class DebugExport
  def print(programmes)
    "".tap do |output|
      programmes.each do |p|
        output << add_newline(p)
        p.years.each do |y|
          output << add_newline(y)

          y.course_modules.each do |cm|
            output << add_newline(cm)

            cm.ect_lessons.each do |l|
              output << add_newline(l)

              l.ect_lesson_parts.each do |lp|
                output << add_newline(lp)
              end

              l.mentor_materials.each do |mm|
                output << add_newline(mm)

                mm.mentor_material_parts.each do |mmp|
                  output << add_newline(mmp)
                end
              end
            end
          end
        end
      end
    end
  end

  def add_newline(str)
    "#{str}\n"
  end
end

def debug(str, level = 1)
  puts (" " * (level * 2)) + str
end
