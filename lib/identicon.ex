defmodule Identicon do
  @moduledoc """
  Converts an input string to an identicon
  """

  def main(input) do
    input
    |> hash_input
    |> get_color
    |> build_grid
    |> remove_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  defp hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  defp get_color(%Identicon.Image{hex: [r, g, b | _rest]} = hex) do
    %Identicon.Image{hex | color: {r, g, b}}
  end

  defp build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.flat_map(fn [first, second | _rest] = row -> row ++ [second, first] end)
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  defp remove_odd_squares(%Identicon.Image{grid: grid} = image) do
    filtered_grid =
      grid
      |> Enum.filter(fn {num, _idx} -> rem(num, 2) == 0 end)

    %Identicon.Image{ image | grid: filtered_grid}
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      grid
      |> Enum.map(&get_pixel_value/1)

    %Identicon.Image{ image | pixel_map: pixel_map}
  end

  defp get_pixel_value({_hex, index}) do
    horizontal = rem(index, 5) * 50
    vertical = div(index, 5) * 50
    top_left = {horizontal, vertical}
    bottom_right = {horizontal + 50, vertical + 50}

    {top_left, bottom_right}
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    image = :egd.render(image)
  end

  defp save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
