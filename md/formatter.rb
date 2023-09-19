class Formatter
  def initialize(raw)
    @raw = raw
    @output = raw.encode(raw.encoding, universal_newline: true)
  end

  def tidy
    replace_youtube!
    remove_weird_characters!
    remove_dollar_capital_i!
    remove_cta!

    replace_details!
    replace_accordion!
    remove_br!
    remove_empty_tags!

    %w(h3 h4 ul ol em strong).each do |tag|
      replace_html_tags!(tag)
    end

    @output
  end

private

  def remove_br!
    @output.gsub!("<br />", "")
  end

  def remove_empty_tags!
    %w(em).each { |tag| @output.gsub!(%r{<#{tag}>[[:space:]]*</#{tag}>}, "") }
  end

  def remove_weird_characters!
    @output.slice!("\u2500")
  end

  def replace_youtube!
    @output.gsub!(/\$YoutubeVideo(.*?)\$EndYoutubeVideo/m) do |inner|
      inner.delete_prefix("$YoutubeVideo").delete_suffix("$EndYoutubeVideo")
    end
  end

  def replace_details!
    @output.gsub!(/\$Details(.*?)\$EndDetails/m) do |inner|
      inner
        .gsub("$Details", "{details}")
        .gsub("$EndDetails", "{/details}")
        .gsub(/\$Heading(.*?)\$EndHeading/m) { |h| h.delete_prefix("$Heading").delete_suffix("$EndHeading").strip + "." }
        .gsub(/\$Content(.*?)\$EndContent/m) { |c| rm(c.delete_prefix("$Content").delete_suffix("$EndContent")) }
    end
  end

  def replace_accordion!
    # TODO: implement this 🪗
  end

  def remove_dollar_capital_i!
    @output.gsub!("$I", "")
  end

  def remove_cta!
    @output.gsub!("$CTA", "")
  end

  def replace_html_tags!(tag)
    @output.gsub!(%r{<#{tag}>(.*?)</#{tag}>}m) { |inner| rm(inner).strip }
  end

  def remove_multiple_blank_lines!
    @output.squeeze!("\n")
  end

  def rm(content)
    ReverseMarkdown.convert(content)
  end
end
