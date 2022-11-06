defmodule TicTacToeWeb.Components.Modal do
  @moduledoc """
  Module For Modal Components
  """
  use Phoenix.Component

  @spec modal(%{
          optional(:id) => String.t()
        }) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Generic component for Modal
  """
  def modal(assigns) do
    default_assigns = %{
      class: "",
      style: "",
      close_button_class: "",
      close_on_esc: true,
      on_close_target: nil,
      inner_block: nil,
      on_close: nil,
      inner_style: "",
      fixed: false,
      overlay_bg: "bg-base-overlay/90"
    }

    assigns =
      if Map.get(assigns, :id) do
        component_id = make_component_id(assigns.id)
        assign(assigns, :id, component_id)
      else
        assigns
      end

    assigns = Map.merge(default_assigns, assigns)

    ~H"""
    <div
      class={
        "w-full flex flex-col fixed inset-0 p-4 " <>
          if @fixed,
            do: "justify-start",
            else: "justify-center" <> " items-center " <> @overlay_bg <> " z-50 cursor-default"
      }
      phx-capture-click={@on_close}
      style={@style}
      phx-target={@on_close_target}
      phx-window-keydown={if @close_on_esc, do: @on_close}
      phx-key={if @close_on_esc, do: "escape"}
    >
      <%= if @fixed do %>
        <div class="h-0 md:h-1/4"></div>
      <% end %>
      <div
        class={
          "relative flex-shrink rounded-md border  " <>
            @class
        }
        style={@inner_style}
      >
        <%= if @on_close do %>
          <button
            class={
              "close_modal_btn absolute z-30 right-0 top-0 pt-6 pr-6 pb-2 pl-2 text-base-50 hover:text-base-60 transition-colors duration-200 " <>
                @close_button_class
            }
            phx-click={@on_close}
            phx-target={@on_close_target}
          >
          <svg class="w-4 h-4 inline-block mb-0.5 select-none">
            <symbol id="times" viewBox="0 0 24 24" fill="currentColor" fill-rule="evenodd" clip-rule="evenodd">
              <path
                d="M19.7397 5.51743C20.0868 5.17029 20.0868 4.60749 19.7397 4.26035C19.3926 3.91322 18.8297 3.91322 18.4826 4.26035L12 10.7429L5.51743 4.26035C5.17029 3.91322 4.60749 3.91322 4.26035 4.26035C3.91322 4.60749 3.91322 5.17029 4.26035 5.51743L10.7429 12L4.26035 18.4826C3.91322 18.8297 3.91322 19.3926 4.26035 19.7397C4.60749 20.0868 5.17029 20.0868 5.51743 19.7397L12 13.2571L18.4826 19.7397C18.8297 20.0868 19.3926 20.0868 19.7397 19.7397C20.0868 19.3926 20.0868 18.8297 19.7397 18.4826L13.2571 12L19.7397 5.51743Z" />
            </symbol>
          </svg>

          </button>
        <% end %>

        <%= if @inner_block do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          <.live_component module={@component} {prepare_assigns_for_subcomponent(assigns)} />
        <% end %>
      </div>
    </div>
    """
  end

  defp make_component_id(modal_id) do
    modal_id <> "_component"
  end

  defp prepare_assigns_for_subcomponent(assigns), do: Map.delete(assigns, :myself)
end
