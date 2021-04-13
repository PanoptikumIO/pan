defmodule PanWeb.Surface.Admin.PaginationLink do
  use Surface.Component

  prop(page, :integer, required: true)
  prop(per_page, :integer, required: true)
  prop(disabled, :css_class, required: false, default: false)
  prop(class, :css_class, required: false)
  prop(target, :string, required: true)

  slot(default, required: true)

  def render(assigns) do
    ~H"""
    <a href="#"
       class={{ "px-2 py-1 text-white bg-lavender hover:bg-lavender-light",
                @class,
                disabled: @disabled }}
       :on-click={{ "paginate", target: @target}}
       phx-value-page={{ @page }}
       phx-value-per-page={{ @per_page }}>
      <slot/>
    </a>
    """
  end
end
