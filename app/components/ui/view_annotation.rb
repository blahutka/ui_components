module UI::ViewAnnotation
  extend ActiveSupport::Concern

  included do
      # This works with Ctrl + V to open component file from browser in IDE
      # if ActionView::Base.annotate_rendered_view_with_filenames
      def before_template
        comment { "BEGIN #{relative_file_path}" }
        super
      end
      # end

      # if ActionView::Base.annotate_rendered_view_with_filenames
      def after_template
        comment { "END #{relative_file_path}" }
        super
      end
    # end

    # def around_template(&block)
    #   component_name = self.class.name
    #   subgroup = if component_name.start_with?("UI::Core")
    #                "core"
    #              elsif component_name.start_with?("UI::Views")
    #                "views"
    #              else
    #                "other"
    #              end
    #   Appsignal.instrument("render_component.#{subgroup}.action_view", component_name, &block)
    # end
  end

  private

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
  #   method.owner.name == "UI::ApplicationComponent::SingleRenderBlockGuard" ||
  #     method.source_location&.first&.include?("/app/ui/application_component/single_render_block_guard.rb")
  # end
end
