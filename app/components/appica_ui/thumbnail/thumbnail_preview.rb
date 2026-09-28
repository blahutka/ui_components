# A compact preview tile: an image cropped to fill with a placeholder fallback, or a colored
# tile framing an icon. Sized in em from one `size:`.
#
# @label Thumbnail
# @logical_path Data Display
# @component AppicaUI::Thumbnail
# @display width wide
class AppicaUI::ThumbnailPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ src ].freeze

  PHOTO = "/carousel/slide-1.jpg"

  # @label Usage
  # @param size [Symbol] select { choices: [2xs, xs, sm, md, lg, xl, 2xl] }
  # @param shape [Symbol] select {{ choices_for AppicaUI::Thumbnail, :shape }}
  # @param variant [Symbol] select {{ choices_for AppicaUI::Thumbnail, :variant }}
  # @param alt text
  def default(size: :xl, shape: :rounded, variant: :image, alt: "Snow-capped mountain peak at sunset")
    phlex do
      Thumbnail(size:, shape:, variant:, src: PHOTO, alt:)
    end
  end

  # @label Sizes
  # Seven presets from `2xs` to `2xl`.
  def sizes
    phlex do
      div(class: "flex flex-wrap items-end justify-center gap-4") do
        AppicaUI::Thumbnail::SIZES.each_key { |size| Thumbnail(size:, src: PHOTO, alt: "Mountain peak") }
      end
    end
  end

  # @label Custom size
  # A number is an exact pixel size; everything inside stays proportional.
  def custom_size
    phlex do
      div(class: "flex items-end gap-4") do
        [ 40, 56, 88 ].each { |size| Thumbnail(size:, src: PHOTO, alt: "Mountain peak") }
      end
    end
  end

  # @label Shape
  def shape
    phlex do
      div(class: "flex items-center gap-4") do
        Thumbnail(size: :xl, shape: :rounded, src: PHOTO, alt: "Mountain peak")
        Thumbnail(size: :xl, shape: :circle, src: PHOTO, alt: "Mountain peak")
      end
    end
  end

  # @label Icon variants
  # The `icon_*` variants frame an icon instead of an image.
  def icon_variants
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-4") do
        {
          icon_soft: :folder, icon_outline: :photo, icon_primary: :bolt, icon_primary_outline: :heart, icon_secondary: :star,
          icon_error: :trash, icon_success: :check, icon_warning: :bell, icon_info: :mail
        }.each { |variant, icon| Thumbnail(variant:, size: :lg) { Icon(icon) } }
      end
    end
  end

  # @label Fallback
  # A missing or failing image shows the placeholder icon - no broken-image glyph.
  def fallback
    phlex do
      div(class: "flex items-center gap-4") do
        Thumbnail(size: :xl, src: "/thumbnail-does-not-exist.jpg", alt: "Unavailable image")
        Thumbnail(size: :xl)
      end
    end
  end

  # @label Media list
  def media_list
    phlex do
      ul(class: "divide-border border-border w-full max-w-90 divide-y rounded-xl border") do
        [
          [ -> { Thumbnail(size: :md, src: PHOTO, alt: "Mountain peak") }, "Summit.jpg", "Image · 2.4 MB" ],
          [ -> { Thumbnail(size: :md, variant: :icon_soft) { Icon(:folder) } }, "Field notes", "Folder · 18 items" ],
          [ -> { Thumbnail(size: :md, variant: :icon_primary) { Icon(:music) } }, "Trailhead.mp3", "Audio · 3:42" ],
          [ -> { Thumbnail(size: :md, variant: :icon_secondary) { Icon(:layout_2) } }, "Moodboard", "Album · 24 photos" ]
        ].each do |thumbnail, title, meta|
          li(class: "flex items-center gap-3 px-4 py-3") do
            instance_exec(&thumbnail)
            div(class: "flex flex-col") do
              span(class: "text-foreground-intense text-sm font-medium") { title }
              span(class: "text-foreground-muted text-xs") { meta }
            end
          end
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl", class: "flex items-center gap-3") do
        Thumbnail(size: :md, src: PHOTO, alt: "القمة.jpg")
        div(class: "flex flex-col") do
          span(class: "text-foreground-intense text-sm font-medium") { "القمة.jpg" }
          span(class: "text-foreground-muted text-xs") { "صورة · 2.4 ميغابايت" }
        end
      end
    end
  end
end
