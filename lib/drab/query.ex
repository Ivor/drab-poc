defmodule Drab.Query do
  require IEx
  require Logger

  def html(socket, query) do
    generic_query(socket, query, "html()")
  end

  def html(socket, query, value) do
    generic_query(socket, query, "html(#{Poison.encode!(value)})")
    # setter functions returns socket, so can be piped
    socket
  end

  def val(socket, query) do
    generic_query(socket, query, "val()")
  end

  def val(socket, query, value) do
    generic_query(socket, query, "val(#{Poison.encode!(value)})")
    socket
  end

  def attr(socket, query, att) do
    generic_query(socket, query, "attr(#{Poison.encode!(att)})")
  end

  def attr(socket, query, att, value) do
    generic_query(socket, query, "attr(#{Poison.encode!(att)}, #{Poison.encode!(value)})")
    socket
  end

  def add_class(socket, query, value) do
    generic_query(socket, query, "addClass(#{Poison.encode!(value)})")
    socket
  end

  def remove_class(socket, query, value) do
    generic_query(socket, query, "removeClass(#{Poison.encode!(value)})")
    socket
  end

  def toggle_class(socket, query, value) do
    generic_query(socket, query, "toggleClass(#{Poison.encode!(value)})")
    socket
  end

  def change_class(socket, query, from_value, to_value) do
    add_class(socket, query, to_value)
    remove_class(socket, query, from_value)
    socket
  end

  defp generic_query(socket, query, get_function, value \\ nil) do
    myself = :erlang.term_to_binary(self())
    sender = Cipher.encrypt(myself)
    Phoenix.Channel.push(socket, "query",  %{query: query, sender: sender, get_function: get_function})
    receive do
      {:got_results_from_client, reply} ->
        reply
    end
  end
end
