def frontmatter(**kwargs)
  fm = kwargs.map do |k, v|
    next if v.nil?
    next if v.empty?

    %(#{k}: "#{v}")
  end

  <<~FRONTMATTER
    ---
    #{fm.compact.join("\n")}
    ---

  FRONTMATTER
end

def h2(text)
  <<~H2
    ## #{text}

  H2
end

def h3(text)
  <<~H3
    ### #{text}

  H3
end
