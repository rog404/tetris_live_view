defmodule TetrisWeb.TetrisView do
  use TetrisWeb, :live_view

  @column 10
  @row 20
  @reset_color "bg-gray-400"
  @yellow "bg-amber-400"
  @red "bg-rose-400"
  @blue "bg-sky-400"
  @green "bg-emerald-400"
  @orange "bg-orange-400"

  @tetrominos %{
    t: [3, 4, 5, 14],
    f: [4, 5, 14, 24],
    n: [5, 14, 15, 24],
    o: [4, 5, 14, 15],
    r: [3, 4, 5, 13],
    s: [4, 5, 13, 14],
    i: [3, 4, 5, 6]
  }

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    socket
    |> assign(:seconds, 0)
    |> handle_initial_values()
    |> handle_initial_cells()
    |> handle_init_tetromino
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center" phx-window-keydown="button">
      <div class="grid grid-cols-10 gap-0.5 border-4 rounded-sm">
        <div
          :for={cell <- @cells}
          class={"rounded-sm #{cell.color} h-10 w-10"}
          phx-click="change_color"
          phx-value-index={cell.index}
        />
      </div>
      <div class="flex flex-col gap-2">
        <button
          class="ml-4 outline bg-green-600 h-10 rounded-sm p-2 text-white hover:bg-green-700"
          phx-click="generate"
        >
          Generate
        </button>
        <button disabled class="ml-4 outline bg-gray-200 h-10 rounded-sm p-2 text-white">
          Rotate
        </button>
        <button
          class="ml-4 outline bg-blue-400 h-10 rounded-sm p-2 text-white hover:bg-blue-600"
          phx-click="start_clock"
        >
          Start
        </button>
        <button
          class="ml-4 outline bg-slate-500 h-10 rounded-sm p-2 text-white hover:bg-slate-700"
          phx-click="reset"
        >
          Reset
        </button>
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
        %{color: @reset_color, index: index, position: nil, tetromino: nil}
      end)

    assign(socket, :cells, cells)
  end

  defp handle_init_tetromino(socket) do
    tetromino = %{
      actual_coordinates: [0, 0, 0, 0],
      new_coordinates: nil,
      color: @reset_color,
      type: nil
    }

    assign(socket, :tetromino, tetromino)
  end

  def handle_info(:tick, %{assigns: %{seconds: 0}} = socket) do
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    socket
    |> update(:tetromino, &fall_tetromino/1)
    |> update(:seconds, &(&1 - 1))
    |> render_tetromino()
    |> then(&{:noreply, &1})
  end

  def handle_event("start_clock", _unsigned_params, socket) do
    :timer.send_interval(1500, self(), :tick)

    {:noreply, assign(socket, :seconds, 100)}
  end

  def handle_event("button", %{"key" => "h"}, socket) do
    socket
    |> update(:tetromino, &turn_tetromino_to(:left, &1))
    |> render_tetromino()
    |> then(&{:noreply, &1})
  end

  def handle_event("button", %{"key" => "l"}, socket) do
    socket
    |> update(:tetromino, &turn_tetromino_to(:right, &1))
    |> render_tetromino()
    |> then(&{:noreply, &1})
  end

  def handle_event("button", %{"key" => "j"}, socket) do
    socket
    |> update(:tetromino, &fall_tetromino/1)
    |> render_tetromino()
    |> then(&{:noreply, &1})
  end

  def handle_event("button", _params, socket), do: {:noreply, socket}

  def handle_event("reset", _unsigned_params, socket) do
    socket
    |> put_flash(:info, "Resetando")
    |> assign(:seconds, 0)
    |> handle_initial_cells()
    |> then(&{:noreply, &1})
  end

  def handle_event("change_color", %{"index" => index}, socket) do
    integer_index = String.to_integer(index)

    {:noreply, change_one_cells_color(socket, integer_index)}
  end

  def handle_event("generate", _unsigned_params, socket) do
    {tetromino_type, coord} = @tetrominos |> Enum.random()
    random_color = [@yellow, @red, @blue, @green, @orange] |> Enum.random()

    tetromino = %{
      actual_coordinates: [0, 0, 0, 0],
      new_coordinates: coord,
      color: random_color,
      type: tetromino_type
    }

    socket
    |> assign(:tetromino, tetromino)
    |> then(&{:noreply, render_tetromino(&1)})
  end

  def handle_event("rotate", _unsigned_params, socket) do
    update(socket, :tetromino, &rotate_tetromino/1)
    |> render_tetromino()
    |> then(&{:noreply, &1})
  end

  def handle_event("down", _unsigned_params, socket) do
    update(socket, :tetromino, &fall_tetromino/1)
    |> render_tetromino()
    |> then(&{:noreply, &1})
  end

  defp fall_tetromino(%{actual_coordinates: actual_coordinates, new_coordinates: nil} = tetromino) do
    %{tetromino | new_coordinates: add_to_array(10, actual_coordinates)}
  end

  defp turn_tetromino_to(
         :left,
         %{actual_coordinates: actual_coordinates, new_coordinates: nil} = tetromino
       ) do
    %{tetromino | new_coordinates: add_to_array(-1, actual_coordinates)}
  end

  defp turn_tetromino_to(
         :right,
         %{actual_coordinates: actual_coordinates, new_coordinates: nil} = tetromino
       ) do
    %{tetromino | new_coordinates: add_to_array(1, actual_coordinates)}
  end

  defp add_to_array(_number, []), do: []

  defp add_to_array(number, [head | tail]), do: [head + number | add_to_array(number, tail)]

  defp change_one_cells_color(socket, index) do
    socket
    |> update(:cells, fn cells ->
      Enum.map(cells, fn
        %{index: ^index} = cell -> %{cell | color: @yellow}
        cell -> cell
      end)
    end)
  end

  defp render_tetromino(%{assigns: %{tetromino: %{new_coordinates: nil}}} = socket), do: socket

  defp render_tetromino(socket) do
    %{actual_coordinates: actual_coordinates, new_coordinates: new_coordinates, color: color} =
      socket.assigns.tetromino

    [old_first, old_second, old_third, old_fourth] = actual_coordinates
    [new_first, new_second, new_third, new_fourth] = new_coordinates

    update(socket, :cells, fn cells ->
      Enum.map(cells, fn
        %{index: ^old_first} = cell -> %{cell | color: @reset_color}
        %{index: ^old_second} = cell -> %{cell | color: @reset_color}
        %{index: ^old_third} = cell -> %{cell | color: @reset_color}
        %{index: ^old_fourth} = cell -> %{cell | color: @reset_color}
        cell -> cell
      end)
    end)
    |> update(:cells, fn cells ->
      Enum.map(cells, fn
        %{index: ^new_first} = cell -> %{cell | color: color}
        %{index: ^new_second} = cell -> %{cell | color: color}
        %{index: ^new_third} = cell -> %{cell | color: color}
        %{index: ^new_fourth} = cell -> %{cell | color: color}
        cell -> cell
      end)
    end)
    |> update(:tetromino, &clean_tetromino/1)
  end

  defp clean_tetromino(%{new_coordinates: nil} = tetromino), do: tetromino

  defp clean_tetromino(tetromino) do
    %{tetromino | actual_coordinates: tetromino.new_coordinates, new_coordinates: nil}
  end

  defp rotate_tetromino(%{type: :o}) do
  end
end
