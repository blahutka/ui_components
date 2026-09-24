require "redcarpet"

# Autoloaded (and reloaded in development) only when Lookbook is present; see engine.rb
module UiComponents
  module Lookbook
    # "On this page" navigation for Lookbook docs pages, like the one on lookbook.build.
    #
    #   <%= UiComponents::Lookbook::TableOfContents.call(page) %>
    #
    # Lookbook renders page markdown with Redcarpet's `with_toc_data`, which gives every
    # heading an id. Building the list with Redcarpet's own HTML_TOC renderer produces the
    # exact same anchors. Levels 2-3 (## and ###) are listed; the page title is the h1.
    class TableOfContents
      LEVELS = 2..3

      def self.call(page, **)
        new(page, **).to_html
      end

      def initialize(page, title: "On this page")
        @page = page
        @title = title
      end

      def to_html
        links = Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC.new(nesting_level: LEVELS.max), fenced_code_blocks: true, tables: true)
          .render(markdown)
          .strip

        return "" if links.empty?

        <<~HTML.html_safe
          <nav class="ui-docs-toc" aria-label="#{ERB::Util.html_escape(@title)}">
            <div class="ui-docs-toc__inner">
              <p class="ui-docs-toc__title">#{ERB::Util.html_escape(@title)}</p>
              #{drop_page_title(links)}
            </div>
          </nav>
          #{STYLES}
        HTML
      end

      private
        # The page source without ERB tags, which aren't headings and would confuse the parser
        def markdown
          @page.content.to_s.gsub(/<%.*?%>/m, "")
        end

        # HTML_TOC nests from level 1; with no "# " headings in the body the top level is empty
        def drop_page_title(links)
          links.sub(/\A<ul>\s*<li>\s*<ul>/, "<ul>").sub(%r{</ul>\s*</li>\s*</ul>\s*\z}, "</ul>")
        end

        STYLES = <<~CSS.freeze
          <style>
            #page-content { position: relative; }
            .ui-docs-toc { font-size: 0.875rem; margin-bottom: 2rem; }
            .ui-docs-toc__inner { border: 1px solid rgb(229 231 235); border-radius: 0.5rem; background: white; }
            .ui-docs-toc__title { margin: 0 !important; padding: 0.75rem 1rem; border-bottom: 1px solid rgb(229 231 235);
              font-size: 0.75rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; }
            .ui-docs-toc ul { list-style: none !important; margin: 0 !important; padding: 0.5rem 1rem 0.75rem !important; }
            .ui-docs-toc ul ul { padding: 0 0 0 0.875rem !important; }
            .ui-docs-toc li { margin: 0.25rem 0 !important; padding: 0 !important; }
            .ui-docs-toc li::before { display: none !important; }
            .ui-docs-toc a { text-decoration: none !important; color: inherit; display: block; line-height: 1.4; }
            .ui-docs-toc a:hover { color: rgb(79 70 229); }
            @media (min-width: 960px) {
              #page-content { padding-right: 14rem; }
              .ui-docs-toc { position: absolute; top: 0; right: 0; bottom: 0; width: 12rem; margin: 0; }
              .ui-docs-toc__inner { position: sticky; top: 1.5rem; max-height: calc(100vh - 8rem); overflow-y: auto; }
            }
          </style>
        CSS
    end
  end
end
