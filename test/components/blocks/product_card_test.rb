require "test_helper"

class Blocks::ProductCardTest < ComponentTestCase
  test "renders the photo, discount, wishlist, prices, options and cart button" do
    html = render_ui do
      ProductCard(name: "Nimbus Runner", description: "Men's running shoes", image: "/shoe.svg", image_alt: "Sneaker", price: 96, original_price: 120) do
        ProductOptions(sizes: %w[ 40 41 42 43 ], selected: "42")
        ProductAddToCart()
      end
    end

    card = html.at_css("div[data-slot=product-card]")
    assert_equal [ "/shoe.svg", "Sneaker" ], %w[src alt].map { |attribute| card.at_css("img")[attribute] }
    assert_equal "−20%", card.at_css("[data-slot=badge]").text
    assert_equal "Add to wishlist", card.at_css("[data-slot=toggle][aria-label]")["aria-label"]
    assert_equal "Nimbus Runner", card.at_css("[data-slot=product-name]").text
    assert_equal "$96", card.at_css("[data-slot=product-price] div").text
    assert_equal "Original price:$120", card.at_css("[data-slot=product-price] s").text

    group = card.at_css("[data-slot=toggle-group]")
    assert_equal [ "Size", "size" ], [ group["aria-label"], group["data-ui--toggle-group-name-value"] ]
    assert_equal %w[ 40 41 42 43 ], group.css("button").map(&:text)
    assert_equal "true", group.at_css("button[value='42']")["aria-pressed"]
    assert_includes group.css("button").last["class"], "hidden"
    assert_equal "quantity", card.at_css("[data-slot=number-field] input[type=hidden]")["name"]
    assert_equal "Add to cart", card.at_css("[data-slot=product-add-to-cart] button").text.strip
  end

  test "with an action it is a form and a full price has no badge" do
    html = render_ui do
      ProductCard(name: "Cap", price: 28, action: "/cart_items", product_id: 7, wishlist: false) { ProductAddToCart() }
    end

    form = html.at_css("form[data-slot=product-card]")
    assert_equal [ "/cart_items", "post" ], [ form["action"], form["method"] ]
    assert_equal "7", form.at_css("input[name=product_id]")["value"]
    assert_equal "submit", form.at_css("button")["type"]
    assert_nil form.at_css("[data-slot=badge]")
    assert_nil form.at_css("[data-slot=toggle]")
    assert_nil form.at_css("s")
    assert form.at_css("[data-slot=product-media] svg"), "a placeholder without a photo"
  end
end
