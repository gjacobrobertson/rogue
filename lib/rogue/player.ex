defmodule Rogue.Player do
  alias Rogue.NameGenerator
  defstruct [:name, :position, :action]

  @type position() :: {integer(), integer()}
  @type direction() :: :up | :down | :left | :right
  @type movement() :: {:movement, direction()}
  @type action() :: nil | movement()
  @type t() :: %__MODULE__{
          name: binary(),
          position: position(),
          action: nil | action()
        }

  def create(position) do
    %__MODULE__{
      name: NameGenerator.generate(),
      position: position
    }
  end

  @spec move(t(), direction()) :: position()
  def move(%__MODULE__{position: {x, y}}, :left), do: {x - 1, y}
  def move(%__MODULE__{position: {x, y}}, :right), do: {x + 1, y}
  def move(%__MODULE__{position: {x, y}}, :up), do: {x, y - 1}
  def move(%__MODULE__{position: {x, y}}, :down), do: {x, y + 1}
  def move(player, _dir), do: player
end
