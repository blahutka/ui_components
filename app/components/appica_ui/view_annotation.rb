module AppicaUI::ViewAnnotation
  extend ActiveSupport::Concern

  # BEGIN/END comments around every component, so a component in the browser can be opened in the
  # IDE. Only when the host has asked for annotated views itself: checked at render time, since the
  # setting is configured after this module is included, and a host that never turned it on must
  # not find component paths in its production HTML or its mail.
  included do
    def before_template
      comment { "BEGIN #{relative_file_path}" } if annotate_rendered_view?
      super
    end

    def after_template
      comment { "END #{relative_file_path}" } if annotate_rendered_view?
      super
    end

    # def around_template(&block)
    #   component_name = self.class.name
    #   subgroup = if component_name.start_with?("AppicaUI::Core")
    #                "core"
    #              elsif component_name.start_with?("AppicaUI::Views")
    #                "views"
    #              else
    #                "other"
    #              end
    #   Appsignal.instrument("render_component.#{subgroup}.action_view", component_name, &block)
    # end
  end

  private

  def annotate_rendered_view?
    ActionView::Base.annotate_rendered_view_with_filenames
  end

  def relative_file_path
    file_path = view_template_source_location.first
    Pathname.new(file_path).relative_path_from(Rails.root).to_s
  end

  def view_template_source_location
    view_template_method = self.class.instance_method(:view_template)
    # view_template_method = view_template_method.super_method while guard_view_template_method?(view_template_method)

    view_template_method.source_location
  end

  # def guard_view_template_method?(method)
  #   method.owner.name == "AppicaUI::ApplicationComponent::SingleRenderBlockGuard" ||
  #     method.source_location&.first&.include?("/app/ui/application_component/single_render_block_guard.rb")
  # end
end
