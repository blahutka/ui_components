# The next arrow. `position:` is :inside (default), :outside, :outside_half or :none.
class AppicaUI::CarouselNext < AppicaUI::CarouselArrow
  POSITIONER = {
    inside: "absolute z-10 data-[orientation=horizontal]:inset-e-4 data-[orientation=horizontal]:top-1/2 data-[orientation=horizontal]:-translate-y-1/2 data-[orientation=vertical]:inset-s-1/2 data-[orientation=vertical]:bottom-4 data-[orientation=vertical]:-translate-x-1/2",
    outside: "absolute z-10 data-[orientation=horizontal]:-inset-e-14 data-[orientation=horizontal]:top-1/2 data-[orientation=horizontal]:-translate-y-1/2 data-[orientation=vertical]:inset-s-1/2 data-[orientation=vertical]:-bottom-14 data-[orientation=vertical]:-translate-x-1/2",
    outside_half: "absolute z-10 data-[orientation=horizontal]:-inset-e-5 data-[orientation=horizontal]:top-1/2 data-[orientation=horizontal]:-translate-y-1/2 data-[orientation=vertical]:inset-s-1/2 data-[orientation=vertical]:-bottom-5 data-[orientation=vertical]:-translate-x-1/2",
    none: nil
  }.freeze

  private
    def direction = "next"
    def label = "Next slide"
    def chevron_icon = :chevron_right
end
