def frontmatter(title:)
  <<~FRONTMATTER
    ---
    title: "#{title}"
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

def h4(text)
  <<~H4
    #### #{text}

  H4
end
