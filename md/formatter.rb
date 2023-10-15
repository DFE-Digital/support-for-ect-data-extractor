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
    replace_figure!
    remove_br!
    remove_section!
    remove_empty_tags!

    %w(h3 h4 ul ol em strong).each do |tag|
      replace_html_tags!(tag)
    end

    remove_emboldened_headings!
    add_empty_lines_beneath_headings!
    fix_consecutive_but_separate_lists!

    fix_material_paths!

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
      inner_without_delimiters = inner.delete_prefix("$YoutubeVideo").delete_suffix("$EndYoutubeVideo")

      code = if inner.include?("https://www.youtube.com")
               inner_without_delimiters.match(%r{https://www.youtube.com/watch\?v=(.*?)[)?&]})[1]
             else
               inner_without_delimiters.match(%r{https://(?:www.)?youtu.be/(.*)[)?&]})[1]
             end

      build_youtube_embed(code)
    end
  end

  def build_youtube_embed(code)
    <<~EMBED
      <iframe width="560" height="315" src="https://www.youtube.com/embed/#{code}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
    EMBED
  end

  def replace_details!
    @output.gsub!(/\$Details(.*?)\$EndDetails/m) do |inner|
      inner
        .gsub("$Details", "{details}")
        .gsub("$EndDetails", "{/details}")
        .gsub(/\$Content(.*?)\$EndContent/m) { |c| c.delete_prefix("$Content").delete_suffix("$EndContent") }
        .gsub(/\$Heading(.*?)\$EndHeading/m) do |heading_text|
          heading_text
            .delete_prefix("$Heading")
            .delete_suffix("$EndHeading")
            .strip
            .tap { |s| s.concat(".") unless s.end_with?(".") }
        end
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

  def replace_figure!
    @output.gsub!(/\$Figure(.*?)\$EndFigure/m) do |inner|
      alt =  inner.match(/\$Alt(?<alt>.*?)\$EndAlt/m)['alt']
      url =  inner.match(/\$URL(?<url>.*?)\$EndURL/m)['url']
      caption = inner.match(/\$Caption(?<caption>.*?)\$EndCaption/m)['caption']

      if !caption.strip.empty?
        <<~FIGURE
          <figure>
            <img url="#{url.strip}" alt="#{alt.strip}" />
            <figcaption>
              #{caption.strip}
            </figcaption>
          </figure>
        FIGURE
      else
        <<~FIGURE
          <figure>
            <img url="#{url.strip}" alt="#{alt.strip}" />
          </figure>
        FIGURE
      end
    end
  end

  def remove_dollar_capital_i!
    @output.gsub!("$I", "")
  end

  def remove_cta!
    @output.gsub!("$CTA", "")
  end

  def remove_section!
    @output.gsub!("$Section", "\n")
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

  def fix_material_paths!
    old_prefix = "https://paas-s3-broker-prod-lon-ac28a7a5-2bc2-4d3b-8d16-a88eaef65526.s3.amazonaws.com/"
    new_prefix = "/assets/materials/"

    @output.gsub!(old_prefix, new_prefix)
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
