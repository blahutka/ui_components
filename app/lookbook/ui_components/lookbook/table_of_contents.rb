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

      # Lookbook's router intercepts every link click and scrolls its content pane back to the
      # top, so the anchors scroll to their heading themselves and stop the event there. (An
      # inline handler survives Lookbook swapping the page in, unlike a <script>.)
      SCROLL_TO_HEADING = "event.preventDefault(); event.stopPropagation(); " \
        "const heading = document.getElementById(decodeURIComponent(this.hash.slice(1))); " \
        "if (heading) { heading.scrollIntoView({ behavior: 'smooth', block: 'start' }); history.replaceState(history.state, '', this.hash) }"

      # Scroll-spy: marks the link of the section being read with aria-current. Runs from
      # Alpine's x-init (Lookbook ships Alpine), which initializes even when Lookbook swaps the
      # page in. A clicked link stays current until its smooth scroll ends.
      SCROLL_SPY = <<~JS.squish.freeze
        const nav = $el;
        const links = [ ...nav.querySelectorAll('a[href^="#"]') ];
        const headings = links.map(link => document.getElementById(decodeURIComponent(link.hash.slice(1))));
        let pane = nav.parentElement;
        while (pane && !/(auto|scroll)/.test(getComputedStyle(pane).overflowY)) pane = pane.parentElement;
        const scroller = pane || window;
        let locked = null;
        let unlock;
        const mark = link => links.forEach(other => other === link ? other.setAttribute('aria-current', 'location') : other.removeAttribute('aria-current'));
        const update = () => {
          if (!nav.isConnected) return scroller.removeEventListener('scroll', update);
          if (locked) return;
          const top = (pane ? pane.getBoundingClientRect().top : 0) + 48;
          const box = pane || document.scrollingElement;
          const atEnd = box.scrollHeight > box.clientHeight && box.scrollTop + box.clientHeight >= box.scrollHeight - 2;
          let current = 0;
          headings.forEach((heading, index) => { if (heading && heading.getBoundingClientRect().top <= top) current = index });
          if (atEnd) current = headings.length - 1;
          mark(links[current]);
        };
        nav.addEventListener('click', event => {
          const link = event.target.closest('a[href^="#"]');
          if (!link) return;
          mark(link);
          locked = link;
          clearTimeout(unlock);
          const release = () => { locked = null; clearTimeout(unlock) };
          scroller.addEventListener('scrollend', release, { once: true });
          unlock = setTimeout(release, 1000);
        }, true);
        scroller.addEventListener('scroll', update, { passive: true });
        update();
        setTimeout(update, 300);
      JS

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
          <nav class="ui-docs-toc" aria-label="#{ERB::Util.html_escape(@title)}" x-data x-init="#{ERB::Util.html_escape(SCROLL_SPY)}">
            <div class="ui-docs-toc__inner">
              <p class="ui-docs-toc__title">#{ERB::Util.html_escape(@title)}</p>
              #{scroll_to_headings(drop_page_title(links))}
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

        def scroll_to_headings(links)
          links.gsub('<a href="#', %(<a onclick="#{SCROLL_TO_HEADING}" href="#))
        end

        STYLES = <<~CSS.freeze
          <style>
            #page-content { position: relative; }
            #page-content :is(h2, h3)[id] { scroll-margin-top: 1.5rem; }
            .ui-docs-toc { font-size: 0.875rem; margin-bottom: 2rem; }
            .ui-docs-toc__inner { border: 1px solid rgb(229 231 235); border-radius: 0.5rem; background: white; }
            .ui-docs-toc__title { margin: 0 !important; padding: 0.75rem 1rem; border-bottom: 1px solid rgb(229 231 235);
              font-size: 0.75rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; }
            .ui-docs-toc ul { list-style: none !important; margin: 0 !important; padding: 0.5rem 1rem 0.75rem !important; }
            .ui-docs-toc ul ul { padding: 0 0 0 0.875rem !important; }
            .ui-docs-toc li { margin: 0.25rem 0 !important; padding: 0 !important; }
            .ui-docs-toc li::before { display: none !important; }
            .ui-docs-toc a { text-decoration: none !important; color: inherit; display: block; line-height: 1.4; }
            .ui-docs-toc a { border-left: 2px solid transparent; margin-left: -0.625rem; padding-left: 0.5rem; transition: color 150ms, border-color 150ms; }
            .ui-docs-toc a:hover { color: rgb(79 70 229); }
            .ui-docs-toc a[aria-current] { color: rgb(79 70 229); border-left-color: rgb(79 70 229); font-weight: 500; }
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
