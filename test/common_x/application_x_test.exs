defmodule ApplicationXTest do
  use ExUnit.Case, async: false
  doctest ApplicationX

  describe "applications" do
    test "falls back tto `:application.loaded_applications`" do
      :meck.new(Mix.Project)
      :meck.expect(Mix.Project, :config, fn -> [] end)
      on_exit(&:meck.unload/0)

      assert :common_x in ApplicationX.applications()
    end
  end

  describe "modules" do
    test "falls back tto `:application.loaded_applications`" do
      :meck.new(Mix.Project)
      :meck.expect(Mix.Project, :config, fn -> [] end)
      on_exit(&:meck.unload/0)

      assert ApplicationX in ApplicationX.modules()
    end
  end
end
