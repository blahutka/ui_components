require "test_helper"

class AppicaUI::ViewAnnotationTest < ComponentTestCase
  setup { @annotate = ActionView::Base.annotate_rendered_view_with_filenames }
  teardown { ActionView::Base.annotate_rendered_view_with_filenames = @annotate }

  # A host embedding these components must not find their source paths in its production HTML
  # or its mail just because the gem is installed.
  test "leaves no comments when the host has not asked for annotated views" do
    ActionView::Base.annotate_rendered_view_with_filenames = false

    html = render_ui { Badge { "Badge" } }.to_html

    assert_no_match(/BEGIN|END/, html)
  end

  test "marks where a component starts and ends when the host has asked for it" do
    ActionView::Base.annotate_rendered_view_with_filenames = true

    html = render_ui { Badge { "Badge" } }.to_html

    assert_match %r{<!-- BEGIN .*appica_ui/badge/badge\.rb -->}, html
    assert_match %r{<!-- END .*appica_ui/badge/badge\.rb -->}, html
  end
end
