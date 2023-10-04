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

    remove_emboldened_headings!
    add_empty_lines_beneath_headings!
    fix_consecutive_but_separate_lists!

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
        .gsub(/\$Content(.*?)\$EndContent/m) { |c| c.delete_prefix("$Content").delete_suffix("$EndContent") }
    end
  end

  def replace_accordion!
    @output.gsub!(/\$Accordion(.*?)\$EndAccordion/m) do |inner|
      inner
        .gsub("$Accordion", "")
        .gsub("$EndAccordion", "")
        .gsub(/\$Heading(.*?)\$EndHeading/m) { |h| h3(h.delete_prefix("$Heading").delete_suffix("$EndHeading").gsub("\n", "")) }
        .gsub(/\$Content(.*?)\$EndContent/m) { |c| rm(c.delete_prefix("$Content").delete_suffix("$EndContent")) }
        .gsub(/\$Content(.*?)\$EndContent/m) { |c| rm(c.delete_prefix("$Content").delete_suffix("$EndContent")) }
        .gsub(/\$Summary(.*?)\$EndSummary/m) { |c| rm(c.delete_prefix("$Summary").delete_suffix("$EndSummary")) }
    end
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

  def remove_emboldened_headings!
    %w(# ## ### #### ##### ######).each do |heading_prefix|
      @output.gsub!(/^#{heading_prefix} \*\*(.*?)\*\*$/) do
        "#{heading_prefix} #{Regexp.last_match[1]}"
      end
    end
  end

  def add_empty_lines_beneath_headings!
    # TODO
    # @output.gsub!(/^###+ (.*)$/) { "#{Regexp.last_match[0]}\n" }
  end

  def add_spaces_above_and_below_lists!
    # TODO
  end

  def fix_consecutive_but_separate_lists!
    # TODO
  end

  def rm(content)
    ReverseMarkdown.convert(content)
  end
end
