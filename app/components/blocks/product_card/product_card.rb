# A product card: a photo with a discount badge and a wishlist toggle, the name, price and
# original price, and whatever the block adds (sizes, quantity, the cart button) - composed from
# Badge, Toggle, Button, ToggleGroup and NumberField.
#
#   ProductCard(name: product.name, description: product.subtitle, image: product.photo_url,
#     price: product.price, original_price: product.list_price, action: cart_items_path) do
#     ProductOptions(sizes: product.sizes, selected: "42")
#     ProductAddToCart()
#   end
#
# With `action:` the card is a form: the size group submits `size`, the quantity `quantity` and
# the hidden `product_id:` - Add to cart posts them. Strings: product_card.locales.yml.
class Blocks::ProductCard < Blocks::Base
  prop :name
  prop :price
  prop :description,    default: -> { nil }
  prop :original_price, default: -> { nil }
  prop :currency,       default: -> { "USD" }
  prop :image,          default: -> { nil }
  prop :image_alt,      default: -> { "" }
  prop :badge,          default: -> { discount }
  prop :wishlist,       default: -> { true }
  prop :wishlisted,     default: -> { false }
  prop :action,         default: -> { nil }
  prop :method,         default: -> { :post }
  prop :product_id,     default: -> { nil }

  def view_template(&)
    card(data: { slot: "product-card" }, class: cn(
      "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
      override: @attributes[:class]
    )) do
      input(type: "hidden", name: "product_id", value: @product_id) if @action && @product_id
      media
      div(class: "mt-3 flex items-start justify-between gap-3") do
        div do
          h3(class: "text-foreground-intense text-sm font-medium", data: { slot: "product-name" }) { @name }
          p(class: "text-foreground-muted text-xs") { @description } if @description
        end
        div(class: "text-end", data: { slot: "product-price" }) do
          div(class: "text-foreground-intense font-semibold tabular-nums") { money(@price) }
          if on_sale?
            s(class: "text-foreground-muted text-xs tabular-nums") do
              span(class: "sr-only") { t(".original_price") }
              plain money(@original_price)
            end
          end
        end
      end
      yield if block_given?
    end
  end

  private
    def card(**attributes, &)
      attributes = mix(attributes, @attributes.except(:class))
      if @action
        form(action: @action, method: (@method.to_s == "get" ? "get" : "post"), **attributes, &)
      else
        div(**attributes, &)
      end
    end

    def media
      div(class: "bg-background-muted relative h-34 overflow-hidden rounded-lg", data: { slot: "product-media" }) do
        if @image
          img(src: @image, alt: @image_alt, loading: "lazy", class: "absolute inset-0 size-full object-cover")
        else
          div(class: "text-foreground-subtle flex size-full items-center justify-center") { Icon(:photo, size: 32) }
        end
        Badge(variant: :light, size: :sm, class: "absolute inset-s-2 top-2") { @badge } if @badge
        wishlist_toggle if @wishlist
      end
    end

    def wishlist_toggle
      Toggle(pressed: @wishlisted, aria_label: t(".wishlist")) do |toggle|
        Button(**toggle, variant: :light, size: :sm, icon: true, class: "absolute inset-e-2 top-2") do
          Icon(:heart, class: "in-data-pressed:hidden")
          Icon(:heart_filled, class: "hidden in-data-pressed:block")
        end
      end
    end

    def on_sale?
      @original_price && @original_price > @price
    end

    # -20% off the original price
    def discount
      return unless on_sale?

      format_percent(-((1 - @price.to_d / @original_price.to_d) * 100).round, sign: true)
    end

    def money(amount)
      format_money(amount, currency: @currency)
    end
end
