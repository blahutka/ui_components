# The previous arrow. `position:` is :inside (default), :outside, :outside_half or :none.
class UI::CarouselPrev < UI::CarouselArrow
  POSITIONER = {
    inside: "absolute z-10 data-[orientation=horizontal]:inset-s-4 data-[orientation=horizontal]:top-1/2 data-[orientation=horizontal]:-translate-y-1/2 data-[orientation=vertical]:inset-s-1/2 data-[orientation=vertical]:top-4 data-[orientation=vertical]:-translate-x-1/2",
    outside: "absolute z-10 data-[orientation=horizontal]:-inset-s-14 data-[orientation=horizontal]:top-1/2 data-[orientation=horizontal]:-translate-y-1/2 data-[orientation=vertical]:inset-s-1/2 data-[orientation=vertical]:-top-14 data-[orientation=vertical]:-translate-x-1/2",
    outside_half: "absolute z-10 data-[orientation=horizontal]:-inset-s-5 data-[orientation=horizontal]:top-1/2 data-[orientation=horizontal]:-translate-y-1/2 data-[orientation=vertical]:inset-s-1/2 data-[orientation=vertical]:-top-5 data-[orientation=vertical]:-translate-x-1/2",
    none: nil
  }.freeze

  private
    def direction = "prev"
    def label = "Previous slide"
    def chevron_path = "m15 6-6 6 6 6"
end
