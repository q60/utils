defmodule Helpers.Cube do
  def scramble() do
    Scrambler.gen_scramble("3x3")
    |> Cubes.apply(Cubes.cube("3x3"))
    |> Cubes.Colors.as_map()
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.merge(
        acc,
        %{
          k =>
            case v do
              "yellow" -> "#FFEE09"
              "orange" -> "#FF8800"
              "green" -> "#00AA55"
              "red" -> "#DD3322"
              "blue" -> "#0099DD"
              "white" -> "#FFFFFF"
            end
        }
      )
    end)
  end
end
