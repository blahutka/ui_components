# The ProductCard's full-width Add to cart button, pinned to the bottom of the card. In a card
# with `action:` it submits the form.
class AppicaUI::Blocks::ProductAddToCart < AppicaUI::Blocks::Base
  prop :label, default: -> { t("ui_components.appica_ui.blocks.product_card.add_to_cart") }

  def view_template
    div(class: "mt-auto pt-4", data: { slot: "product-add-to-cart" }) do
      Button(type: "submit", size: :sm, **@attributes, class: cn("w-full", override: @attributes[:class])) do
        Icon(:shopping_cart, data: { icon: "start" })
        plain @label
      end
    end
  end
end
