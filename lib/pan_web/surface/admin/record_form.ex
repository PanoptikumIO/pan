defmodule PanWeb.Surface.Admin.RecordForm do
  use Surface.LiveComponent
#  alias PanWeb.Router.Helpers, as: Routes
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  import PanWeb.Surface.Admin.ColumnsFilter
  alias PanWeb.Surface.Submit

  alias PanWeb.Surface.Admin.{
    CheckBoxField,
    NumberField,
    TextAreaField,
    TextField,
    DateTimeSelect
  }

  prop(record, :map, required: true)
  prop(resource, :module, required: true)
  prop(path_helper, :atom, required: true)

  data(changeset, :map)
  slot(columns)

  def update(assigns, socket) do
    {:ok,
     assign(socket |> assign(assigns),
       changeset: assigns.record |> assigns.resource.changeset()
     )}
  end

  def name(struct) do
    struct.__struct__
    |> to_string()
    |> String.split(".")
    |> List.last()
  end

  def handle_event("validate", full_params, socket) do
    resource_string = socket.assigns.resource |> to_string()
    resource_name = resource_string |> Phoenix.Naming.resource_name()
    params = full_params[resource_name]
    named_struct = resource_string |> String.to_atom() |> Kernel.struct()

    changeset =
      socket.assigns.resource.changeset(named_struct, params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def render(assigns) do
    ~H"""
    <div id={{ @id }}>
      <h2 class="text-2xl">
        <span class="text-gray-dark">
          Edit <span class="font-semibold">{{ name(@record) }}</span>
        </span> &nbsp; {{ @record.title }}
      </h2>

      <Form for={{ @changeset }}
            opts={{ autocomplete: "off",
                    class: "mt-4",
                    phx_change: :validate,
                    phx_submit: :save,
                    phx_target: "#" <> @id }}>
        <Field :if={{ !@changeset.valid? }}
                name="error"
                class="inline-block px-2 mb-2
                text-grapefruit bg-grapefruit bg-opacity-20
                border border-grapefruit border-dotted">
          An error occured. Please check the errors below!
        </Field>

        <div class="flex flex-col space-y-4 xl:space-y-0 xl:flex-row xl:space-x-4">
          <fieldset class="border border-gray bg-gray-lightest rounded-xl p-2">
            <legend class="px-4 border border-gray rounded-lg bg-white">Numeric Fields</legend>
            <NumberField :for={{ column <- number_columns(assigns) }}
                          name={{ column.field }} />
          </fieldset>
          <fieldset class="border border-gray bg-gray-lightest rounded-xl p-2">
            <legend class="px-4 border border-gray rounded-lg bg-white">Date & Time Fields</legend>
            <DateTimeSelect :for={{ column <- datetime_columns(assigns) }}
                            name={{ column.field }} />
          </fieldset>
          <fieldset class="border border-gray bg-gray-lightest rounded-xl p-2">
          <legend class="px-4 border border-gray rounded-lg bg-white">Boolean Fields</legend>
            <CheckBoxField :for={{ column <- boolean_columns(assigns) }}
                          name={{ column.field }}
                          label={{ column.field }}/>
          </fieldset>
        </div>

        <div class="mt-4 flex flex-col xl:flex-row xl:space-x-4 w-full">
          <fieldset class="flex-1 border border-gray bg-gray-lightest rounded-xl p-2">
            <legend class="px-4 border border-gray rounded-lg bg-white">String Fields</legend>
            <TextField :for={{ column <- string_columns(assigns) }}
                      name={{ column.field }} />
          </fieldset>
          <fieldset class="flex-1 border border-gray bg-gray-lightest rounded-xl p-2">
            <legend class="px-4 border border-gray rounded-lg bg-white">Text Fields</legend>
            <TextAreaField :for={{ column <- text_columns(assigns) }}
                          name={{ column.field }} />
          </fieldset>
        </div>

         <Submit label="Save" />
      </Form>
    </div>
    """
  end
end
