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
    t: [3, 4, 5, 14]
    # f: [4, 5, 14, 24],
    # n: [5, 14, 15, 24],
    # o: [4, 5, 14, 15],
    # r: [3, 4, 5, 13],
    # s: [4, 5, 13, 14],
    # i: [3, 4, 5, 6]
  }

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
      <div class="flex flex-col gap-2">
        <button
          class="ml-4 outline bg-green-600 h-10 rounded-sm p-2 text-white hover:bg-green-700"
          phx-click="gen_tetromino"
        >
          Gerar Bloco
        </button>
        <button
          class="ml-4 outline bg-amber-600 h-10 rounded-sm p-2 text-white hover:bg-amber-700"
          phx-click="rot_tetromino"
        >
          Girar
        </button>
        <button
          class="ml-4 outline bg-slate-500 h-10 rounded-sm p-2 text-white hover:bg-slate-700"
          phx-click="reset_table"
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

  def handle_event("reset_table", _unsigned_params, socket) do
    socket = put_flash(socket, :info, "Tabela Resetada")

    {:noreply, handle_initial_cells(socket)}
  end

  def handle_event("change_color", %{"index" => index}, socket) do
    integer_index = String.to_integer(index)

    {:noreply, change_one_cells_color(socket, integer_index)}
  end

  def handle_event("gen_tetromino", _unsigned_params, socket) do
    {tetromino, coord} = @tetrominos |> Enum.random()
    random_color = [@yellow, @red, @blue, @green, @orange] |> Enum.random()

    {:noreply, generate_tetromino(socket, {tetromino, coord, 0}, random_color)}
  end

  def handle_event("rot_tetromino", _unsigned_params, socket) do
    cells = socket.assigns.cells

    filtered_cells = Enum.filter(cells, &(&1.tetromino != nil))
    coord = Enum.map(filtered_cells, & &1.index)

    %{color: color, position: position, tetromino: tetromino} = List.first(filtered_cells)

    {new_coord, new_position} = rotate_tetromino(coord, tetromino, position)

    {:noreply, generate_tetromino(socket, {tetromino, new_coord, new_position}, color)}
  end

  defp change_one_cells_color(socket, index) do
    socket
    |> update(:cells, fn cells ->
      Enum.map(cells, fn
        %{index: ^index} = cell -> %{cell | color: @yellow}
        cell -> cell
      end)
    end)
  end

  defp generate_tetromino(socket, {tetromino_id, [first, second, third, fourth], position}, color) do
    socket
    |> handle_initial_cells()
    |> update(:cells, fn cells ->
      Enum.map(cells, fn
        %{index: ^first} = cell ->
          %{cell | color: @blue, position: position, tetromino: tetromino_id}

        %{index: ^second} = cell ->
          %{cell | color: @yellow, position: position, tetromino: tetromino_id}

        %{index: ^third} = cell ->
          %{cell | color: @green, position: position, tetromino: tetromino_id}

        %{index: ^fourth} = cell ->
          %{cell | color: @red, position: position, tetromino: tetromino_id}

        cell ->
          cell
      end)
    end)
  end

  defp rotate_tetromino(array, :i, 0) do
    {sum_list(array, [1, 10, 19, 28]), 1}
  end

  defp rotate_tetromino(array, :i, 1) do
    {sum_list(array, [-1, -10, -19, -28]), 0}
  end

  defp rotate_tetromino(array, :t, 0) do
    {sum_list(array, [2, 11, 20, 0]), 1}
  end

  defp rotate_tetromino(array, :t, 1) do
    {sum_list(array, [10, 0, -2, -21]), 2}
  end

  defp rotate_tetromino(array, :t, 2) do
    {sum_list(array, [19, 0, -11, -1]), 3}
  end

  defp rotate_tetromino(array, :t, 3) do
    {sum_list(array, [0, 0, 0, 0]), 0} |> dbg()
  end

  defp rotate_tetromino(array, :f, 0) do
    {sum_list(array, [11, 20, 0, -11]), 1}
  end

  defp rotate_tetromino(array, :n, 0) do
    {sum_list(array, [11, -9, 0, -20]), 1}
  end

  defp rotate_tetromino(array, :r, 0) do
    {sum_list(array, [1, 10, 19, -10]), 1}
  end

  defp rotate_tetromino(array, :s, 0) do
    {sum_list(array, [20, 9, -10, -1]), 1}
  end

  defp rotate_tetromino(array, _, _), do: {array, 0}

  defp sum_list([], []), do: []
  defp sum_list([h1 | t1], [h2 | t2]), do: [h1 + h2] ++ sum_list(t1, t2)
end
