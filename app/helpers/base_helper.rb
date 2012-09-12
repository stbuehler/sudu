module BaseHelper
  def notices
    return [] unless flash[:notice]
    flash[:notice].is_a?(Array) ? flash[:notice] : [flash[:notice]]
  end

  def alerts
    return [] unless flash[:alert]
    flash[:alert].is_a?(Array) ? flash[:alert] : [flash[:alert]]
  end

  def flash_clear
    flash.clear
  end

  def menu_link(title, path, classes='')
    if request.fullpath == path
      ('<li class="active ' + classes + '">' + link_to(title, path) + '</li>').html_safe
    else 
      ('<li class="' + classes + '">' + link_to(title, path) + '</li>').html_safe
    end
  end

  module Markdown
    class SuduMarkdownRenderer < Redcarpet::Render::HTML
      include Rails.application.routes.url_helpers

      def initialize(options={})
        super options.merge(:no_styles => true, :hard_wrap => true)
      end

      def normal_text(text)
        text.gsub(%r{#[0-9]+}m) do |match|
          '<a href="' + todo_item_path(match[1..-1].to_i) + '">' + match + '</a>'.html_safe
        end
      end
    end

    def markdown(txt)
      markdown = Redcarpet::Markdown.new(SuduMarkdownRenderer, {
        :fenced_code_blocks => true,
        :no_intra_emphasis => true,
        :autolink => true,
        :strikethrough => true,
        :lax_html_blocks => true,
        :space_after_headers => true,
        :superscript => true
      })
      markdown.render(txt).html_safe
    end
  end

  include Markdown
end
