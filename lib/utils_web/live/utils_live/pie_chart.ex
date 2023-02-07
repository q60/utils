defmodule UtilsWeb.UtilsLive.PieChart do
  use UtilsWeb, :live_view

  alias Helpers.Cube
  alias Helpers.Colors

  defp polar_to_cartesian(rx, ry, r, angle) do
    radians = (angle - 90) * :math.pi() / 180

    %{
      x: rx + r * :math.cos(radians),
      y: ry + r * :math.sin(radians)
    }
  end

  attr :x, :float
  attr :y, :float
  attr :r, :float
  attr :start_angle, :float
  attr :end_angle, :float
  attr :fill, :string, default: "black"
  attr :class, :string, default: ""
  attr :id, :string, default: ""

  defp arc(assigns) do
    ~H"""
    <% start_cartesian = polar_to_cartesian(@x, @y, @r, @end_angle)
    end_cartesian = polar_to_cartesian(@x, @y, @r, @start_angle)
    large_arc_flag = (@end_angle - @start_angle <= 180 && 0) || 1 %>
    <path
      stroke="white"
      d={"M#{start_cartesian.x},#{start_cartesian.y}\
          A#{@r},#{@r},0,#{large_arc_flag},0,#{end_cartesian.x},#{end_cartesian.y}\
          L#{@x},#{@y}"}
      fill={@fill}
      class={@class}
      id={@id}
    />
    """
  end

  attr :chances, :list
  attr :colors, :list, default: Colors.hex()
  attr :class, :string, default: ""

  def pie_chart(assigns) do
    # TODO: make this more readable
    ~H"""
    <svg version="1.1" width="650" height="650" xmlns="http://www.w3.org/2000/svg" class={@class}>
      <%= chances =
        @chances
        |> Enum.reduce(%{}, fn {k, v}, acc -> Map.merge acc, %{k => v/Enum.sum(Map.values(@chances))*100} end)

      angles = chances |> Enum.map(fn {_, chance} -> chance*3.6 end)
      categories = chances |> Enum.map(fn {text, _} -> text end)
      colors = Enum.take_random(@colors, length(Map.keys(chances)))
      start_angles = angles |> Enum.drop(-1) |> Enum.reduce([0], fn angle, acc -> acc ++ [List.last(acc)+angle] end)
      angle_pairs = Enum.zip_with([start_angles, angles], fn [a, b] -> {a, a+b} end)
      [x, y, r] = [325.0, 325.0, 220.0]
      for {{a, b}, c} <- Enum.zip([angle_pairs, colors]) do %>
        <.arc
          x={x}
          y={y}
          r={r}
          start_angle={a}
          end_angle={b}
          fill={c}
          id={"s#{Base.encode16(inspect(b))}"}
        />
      <% end %>
      <%= for {{a, b}, _, text} <- Enum.zip([angle_pairs, colors, categories]) do %>
        <% t = a + b %>
        <style>
          #s<%= Base.encode16(inspect(b)) %>:hover ~ #p<%= Base.encode16(inspect(b)) %> {
          stroke: black;
          }
          #s<%= Base.encode16(inspect(b)) %>:hover ~ #c<%= Base.encode16(inspect(b)) %> {
          fill: black;
          }
          #s<%= Base.encode16(inspect(b)) %>:hover ~ #t<%= Base.encode16(inspect(b)) %> {
          filter: opacity(0%);
          transition: .3s;
          }
          #s<%= Base.encode16(inspect(b)) %>:hover ~ #l<%= Base.encode16(inspect(b)) %> {
          visibility: visible;
          transition: .3s;
          }
          #s<%= Base.encode16(inspect(b)) %>:hover {
          filter: brightness(60%);
          transition: .3s;
          }
        </style>
        <% dot = polar_to_cartesian(x, y, r * 2 / 3, t / 2)
        %{x: tx, y: ty} = polar_to_cartesian(x, y, r * 2 / 3, 0)

        {text?, path?} =
          cond do
            chances[text] < 3 and Enum.count(Map.values(chances), &(&1 < 3)) == 1 ->
              {"visible", "black"}

            true ->
              {"invisible", "none"}
          end %>
        <circle
          cx={"#{dot.x}"}
          cy={"#{dot.y}"}
          r="2"
          id={"c#{Base.encode16(inspect(b))}"}
          fill={path?}
        />
        <%= unless chances[text] < 3 do %>
          <g transform={"rotate(#{t/2}, #{x}, #{y})"} id={"t#{Base.encode16(inspect(b))}"}>
            <g transform={"rotate(#{t/2 > 180 && 90 || -90}, #{tx}, #{ty})"}>
              <text
                x={"#{tx}"}
                y={"#{ty}"}
                text-anchor="middle"
                class="text-xl font-['IBM_Plex_Mono']"
              >
                <%= text %>
              </text>
            </g>
          </g>
        <% end %>
        <% offset =
          cond do
            t / 2 >= 90 and t / 2 < 180 -> -35
            t / 2 >= 180 and t / 2 <= 270 -> 35
            true -> 0
          end

        %{x: lx, y: ly} = polar_to_cartesian(dot.x, dot.y, 120, t / 2 + offset) %>
        <%= if (b-a)/2+a < 180 do %>
          <path
            id={"p#{Base.encode16(inspect(b))}"}
            d={"M#{dot.x},#{dot.y} L #{lx} #{ly} L #{lx+50} #{ly}"}
            stroke={path?}
            stroke-width="2"
            fill="none"
          />
          <text
            x={"#{lx+5}"}
            y={"#{ly-5}"}
            class={"#{text?} text-sm font-['Iosevka_Term_Slab']"}
            id={"l#{Base.encode16(inspect(b))}"}
          >
            <%= "#{text} #{chances[text] |> Float.round(2)}%" %>
          </text>
        <% else %>
          <path
            id={"p#{Base.encode16(inspect(b))}"}
            d={"M#{dot.x},#{dot.y} L #{lx} #{ly} L #{lx-50} #{ly}"}
            stroke-width="2"
            stroke={path?}
            fill="none"
          />
          <text
            x={"#{lx-45}"}
            y={"#{ly-5}"}
            class={"#{text?} text-sm font-['Iosevka_Term_Slab']"}
            id={"l#{Base.encode16(inspect(b))}"}
          >
            <%= "#{text} #{chances[text] |> Float.round(2)}%" %>
          </text>
        <% end %>
      <% end %>
    </svg>
    """
  end

  def mount_default(socket, reply, params \\ []) do
    {reply,
     assign(
       socket,
       Keyword.merge(
         [page_title: "pie chart", scramble: Cube.scramble()],
         params
       )
     )}
  end

  def mount(_, _, socket) do
    mount_default(socket, :ok, items_number: 1, chart: %{}, items: %{})
  end

  def handle_event(
        "chart",
        %{"chart" => %{"text" => text, "id" => id, "chance" => chance}},
        socket
      ) do
    chance =
      case Float.parse(chance) do
        {f, _} -> f
        :error -> 1
      end

    socket
    |> update(:chart, &Map.merge(&1, %{text => chance}))
    |> update(:items, &Map.merge(&1, %{String.to_integer(id) => %{text: text, chance: chance}}))
    |> mount_default(:noreply)
  end

  def handle_event("add-item", _, socket) do
    socket
    |> update(:items_number, &(&1 + 1))
    |> mount_default(:noreply)
  end

  def handle_event("remove-item", %{"id" => id}, socket) do
    socket
    |> update(:items_number, &(&1 - 1))
    |> update(:items, &Map.delete(&1, String.to_integer(id)))
    |> mount_default(:noreply)
  end
end
