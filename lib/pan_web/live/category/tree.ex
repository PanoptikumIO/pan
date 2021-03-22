defmodule PanWeb.Live.Category.Tree do
  use Surface.LiveView
  alias PanWeb.Category
  alias PanWeb.Surface.CategoryButton

  def mount(_params, _session, socket) do
    {:ok, assign(socket, categories: Category.tree())}
  end

  def render(assigns) do
    ~H"""
    <div class="up-to-four-columns w-full">
      <div :for.with_index={{ {category, counter} <- @categories }}
           class="inline-block mx-2 my-4">
        <p>
          <CategoryButton for={{ category }}
                          large="true"
                          index_on_page={{ counter }} />
        </p>
        <p class="mt-6 -mx-0.5">
          <For each={{ subcategory <- category.children }}>
            <CategoryButton for={{ subcategory }}
                            class="px-1.5 py-0.5 mx-0.5" truncate />
          </For>
        </p>
        <hr class="w-full mt-4 border-t-1 border-gray-lightest" style="break-before: avoid;" />
      </div>
    </div>
    """
  end
end
