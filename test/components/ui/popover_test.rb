require "test_helper"

class UI::PopoverTest < ComponentTestCase
  test "a click trigger wired to a labelled top-layer popup with an arrow" do
    popover = render_ui do
      Popover(id: "p") do
        PopoverTrigger(open_on_hover: true, delay: 150) { |trigger| Button(**trigger, variant: :outline) { "Share" } }
        PopoverContent(side: :top, align: :start) do
          PopoverTitle { "Share" }
          PopoverDescription { "Anyone with the link" }
          PopoverClose { |close| Button(**close) { "Done" } }
        end
      end
    end
    root = popover.at_css("[data-slot=popover]")
    trigger = popover.at_css("[data-slot=popover-trigger]")
    popup = popover.at_css("[data-slot=popover-popup]")

    assert_equal [ "ui--popover", "true" ], [ root["data-controller"], root["data-ui--popover-click-value"] ]
    assert_equal [ "dialog", "false", "p-popup", "true", "150" ], [ trigger["aria-haspopup"], trigger["aria-expanded"], trigger["aria-controls"], trigger["data-hover"], trigger["data-delay"] ]
    assert_equal [ "manual", "dialog", "p-title", "p-description", "top", "start", "10" ],
      [ popup["popover"], popup["role"], popup["aria-labelledby"], popup["aria-describedby"], popup["data-side"], popup["data-align"], popup["data-side-offset"] ]
    assert_includes popover.at_css("[data-slot=popover-content]")["class"], "group-data-[side=top]/popup:border-b-2"
    assert popover.at_css("[data-slot=popover-arrow] svg")
    assert_equal "ui--popover#close", popover.at_css("[data-slot=popover-content] button")["data-action"]
  end

  test "arrow: false drops the arrow and tightens the offset" do
    popup = render_ui { Popover { PopoverContent(arrow: false) { "x" } } }

    assert_nil popup.at_css("[data-slot=popover-arrow]")
    assert_equal "6", popup.at_css("[data-slot=popover-popup]")["data-side-offset"]
  end

  test "PreviewCard: a link trigger, hover / focus with delays, the card in a template" do
    card = render_ui { PreviewCard(id: "c") { PreviewCardTrigger(href: "/u") { "@user" }; PreviewCardContent { "Profile" } } }
    root = card.at_css("span[data-slot=preview-card]")

    assert_equal [ "true", "true", "600", "300" ], %w[ hover focus delay close-delay ].map { |value| root["data-ui--popover-#{value}-value"] }
    assert_equal [ "/u", "c-popup" ], card.at_css("a[data-slot=preview-card-trigger]").then { |link| [ link["href"], link["aria-describedby"] ] }
    template = card.at_css("template[data-ui--popover-target=template]")
    assert template
    assert_includes template.inner_html, "preview-card-popup"
  end

  test "Tooltip: a described trigger, a tooltip bubble, provider settings" do
    tooltip = render_ui do
      TooltipProvider(delay: 400) do
        Tooltip(id: "t", track_cursor_axis: :x) do
          TooltipTrigger { |trigger| Button(**trigger, icon: true, aria_label: "Like") { "♥" } }
          TooltipContent(side: :bottom) { "Like" }
        end
      end
    end
    root = tooltip.at_css("[data-slot=tooltip]")
    bubble = tooltip.at_css("[data-slot=tooltip-content]")

    assert_equal "400", tooltip.at_css("[data-slot=tooltip-provider]")["data-delay"]
    assert_equal [ "true", "false", "true", "x" ], %w[ hover interactive close-on-click track ].map { |value| root["data-ui--popover-#{value}-value"] }
    assert_equal "t-popup", tooltip.at_css("button")["aria-describedby"]
    assert_nil tooltip.at_css("button")["aria-haspopup"]
    assert_equal [ "tooltip", "manual", "bottom", "8" ], [ bubble["role"], bubble["popover"], bubble["data-side"], bubble["data-side-offset"] ]
    assert tooltip.at_css("[data-slot=tooltip-arrow]")
    assert_nil render_ui { Tooltip(disabled: true) { TooltipTrigger { "x" } } }.at_css("[data-slot=tooltip]")["data-controller"]
  end
end
