defmodule TetrisWeb.TetrisView do
  use TetrisWeb, :live_view

  @column 10
  @row 20
  @reset_color "bg-gray-400"
  @yellow "bg-yellow-300"

  def mount(_params, _session, socket) do
    socket
    |> handle_initial_values()
    |> handle_initial_cells()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center">
      <div class="grid grid-cols-10 gap-0.5 border-4 rounded-sm">
        <div
          :for={cell <- @cells}
          class={"rounded-sm #{cell.color} h-10 w-10"}
          phx-click="change_color"
          phx-value-index={cell.index}
        />
      </div>
    </div>
    """
  end

  defp handle_initial_values(socket) do
    socket
    |> assign(:column, @column)
    |> assign(:cell_count, @column * @row)

    # |> assign(:row, @row)
  end

  defp handle_initial_cells(socket) do
    cells =
      0..(@column * @row - 1)
      |> Enum.map(fn index ->
        %{color: @reset_color, index: index}
      end)

    assign(socket, :cells, cells)
  end

  def handle_event("change_color", %{"index" => index}, socket) do
    integer_index = String.to_integer(index)

    socket =
      socket
      |> update(:cells, fn cells ->
        Enum.map(cells, fn
          %{index: ^integer_index} = cell -> %{cell | color: @yellow}
          cell -> cell
        end)
      end)

    {:noreply, socket}
  end
end
