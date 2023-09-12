def query(query, columns, db=$db)
  db.exec(query) do |rs|
    rs
      .map { |row| row.values_at(*columns) }
      .map { |row| columns.zip(row).to_h.transform_keys(&:to_sym) }
  end
end
