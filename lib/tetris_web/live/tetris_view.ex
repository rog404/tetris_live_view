defmodule TetrisWeb.TetrisView do
  use TetrisWeb, :live_view

  @column 10
  @row 20
  @reset_color "bg-gray-400"

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
        <div :for={_cell_number <- 1..@cell_count} class="rounded-sm bg-gray-400 h-10 w-10" />
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
    1..(@column * @row)
    |> Enum.reduce(socket, fn cell_number, acc ->
      cell_attribute = %{color: @reset_color}
      assign(acc, String.to_atom("cell_#{cell_number}"), cell_attribute)
    end)
  end
end
