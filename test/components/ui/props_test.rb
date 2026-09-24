require "test_helper"

class UI::PropsTest < ComponentTestCase
  class Card < UI::Base
    include UI::Props

    param :kind, ->(value) { value.to_s.downcase.to_sym }, default: -> { :note }
    prop :title
    prop :tone, ->(value) { value.to_sym }, default: -> { :muted }

    def view_template(&)
      div(**@attributes, data: { kind: @kind, tone: @tone }) do
        h2 { @title }
        yield if block_given?
      end
    end
  end

  class HandWritten < UI::Base
    include UI::Props

    def initialize(label:, **attributes)
      @label, @attributes = label, attributes
    end

    def view_template = span(**@attributes) { @label }
  end

  test "declared props become ivars, other keywords are the element attributes" do
    card = Card.new("TIP", title: "Hello", id: "card", class: "p-4")

    assert_equal :tip, card.instance_variable_get(:@kind)
    assert_equal "Hello", card.instance_variable_get(:@title)
    assert_equal :muted, card.instance_variable_get(:@tone)
    assert_equal({ id: "card", class: "p-4" }, card.instance_variable_get(:@attributes))
  end

  test "renders with defaults, coercion and the content block" do
    html = Nokogiri::HTML5.fragment(Card.new(title: "Hi", tone: "loud", aria_label: "Card").call { "body" })
    div = html.at_css("div")

    assert_equal "note", div["data-kind"]
    assert_equal "loud", div["data-tone"]
    assert_equal "Card", div["aria-label"]
    assert_equal "Hi", div.at_css("h2").text
  end

  test "no reader methods, so props never shadow Phlex elements" do
    assert_equal Phlex::HTML::StandardElements, Card.instance_method(:title).owner
    refute Card.method_defined?(:tone)
    assert_raises(KeyError, ArgumentError) { Card.new }
  end

  test "classes with their own initialize are left alone" do
    html = Nokogiri::HTML5.fragment(HandWritten.new(label: "Hi", id: "x").call)

    assert_equal "x", html.at_css("span")["id"]
  end
end
