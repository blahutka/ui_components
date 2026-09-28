# A product card: photo with a discount badge and a wishlist toggle, name and prices, a size
# picker, a quantity field and Add to cart - composed from Badge, Toggle, Button, ToggleGroup
# and NumberField.
#
# Localized: switch the toolbar's **Locale** display option and the labels and prices follow.
#
# @label Product card
# @logical_path Blocks
# @component AppicaUI::Blocks::ProductCard
# @display width wide
class AppicaUI::Blocks::ProductCardPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ badge action product_id ].freeze

  # @label Usage
  # The Appica homepage card. The discount badge is computed from the two prices.
  # @param price number
  # @param original_price number
  # @param currency [Symbol] select {{ CURRENCIES }}
  # @param wishlisted [Boolean] toggle
  # @param wishlist [Boolean] toggle
  # @param method text
  # @param name text
  # @param description text
  # @param image text
  # @param image_alt text
  def default(price: 96, original_price: 120, currency: :USD, wishlisted: false, wishlist: true, method: "post", name: "Nimbus Runner", description: "Men's running shoes", image: "/landing/nimbus-runner.svg", image_alt: "Nimbus Runner sneaker on a pastel background")
    phlex do
      ProductCard(price:, original_price:, currency:, wishlisted:, wishlist:, method:, name:, description:, image:, image_alt:, class: "w-95 max-w-full") do
        ProductOptions(sizes: %w[ 40 41 42 43 ], selected: "42")
        ProductAddToCart()
      end
    end
  end

  # @label Add to cart form
  # With `action:` the card is a form posting `product_id`, `size` and `quantity`.
  def form
    phlex do
      ProductCard(name: "Nimbus Runner", description: "Men's running shoes", image: "/landing/nimbus-runner.svg",
        price: 96, original_price: 120, action: "/cart_items", product_id: 42, class: "w-95 max-w-full") do
        ProductOptions(sizes: %w[ 40 41 42 43 ], selected: "42")
        ProductAddToCart()
      end
    end
  end

  # @label Full price, no photo
  # No original price means no badge; a missing image shows a placeholder.
  def simple
    phlex do
      ProductCard(name: "Trail Cap", description: "Unisex, one size", price: 28, wishlist: false, class: "w-95 max-w-full") do
        ProductOptions(quantity: 2)
        ProductAddToCart()
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          ProductCard(name: "نيمبوس رانر", description: "أحذية جري رجالية", image: "/landing/nimbus-runner.svg",
            price: 96, original_price: 120, class: "w-95 max-w-full") do
            ProductOptions(sizes: %w[ 40 41 42 43 ], selected: "42")
            ProductAddToCart()
          end
        end
      end
    end
  end
end
