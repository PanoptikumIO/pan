defmodule PanWeb.Surface.Tab do
  use Surface.Component
  alias Surface.Components.Link

  prop items, :list, required: true

  slot default, props: [item: ^items]

  def render(assigns) do
    ~H"""
    <div x-data="{ selectedTab: 0 }" class="pt-0.5">
      <ul class="flex flex-wrap border-b border-light-gray">
        <li :for.index={{ @items }}
            class="-mb-px ml-1.5">
          <Link class="inline-block rounded-t px-2 py-1.5 font-semibold text-medium-gray hover:text-link-dark border-light-gray"
                :class="{ 'bg-white border-l border-t border-r text-dark-gray' : selectedTab === {{ index }},
                          'bg-light-gray' : selectedTab !== {{ index }} }"
                @click.prevent="selectedTab = {{ index }}"
                to="#"
                label={{ index + 1 }} />
        </li>
      </ul>
      <div class="p-4">
        <div :for.with_index={{ {item, index} <- @items }}
             x-show="selectedTab === {{ index }}">
          <slot :props={{ item: item }} />
        </div>
      </div>
    </div>
    """
  end
end