class Programme
  attr_reader :id, :name
  attr_accessor :years

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def self.all(sql: "select * from core_induction_programmes;", projection: %w(id name))
    query(sql, projection).map { |cip| new(**cip) }
  end

  def to_s
    "".tap do |output|
      output << debug(name)

      years.each do |y|
        output << debug(y)

        y.course_modules.each do |cm|
          output << debug(cm)
        end
      end
    end
  end

private

  def debug(str)
    "#{str}\n"
  end
end
