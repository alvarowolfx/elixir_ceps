defmodule ElixirCeps do
  def fetch_cep(cep) do
    url = "http://viacep.com.br/ws/#{cep}/json/"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        File.write!("./db/#{cep}.json", body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Failed to fetch #{cep}")
        IO.inspect(reason)
    end
  end

  def run do
    HTTPoison.start()

    content =
      case File.read("ceps.txt") do
        {:ok, file} ->
          file

        {:error, msg} ->
          IO.puts("Error opening file : #{msg}")
          exit(1)
      end

    tasks =
      content
      |> String.split("\n")
      |> Enum.map(fn cep ->
        Task.async(fn ->
          fetch_cep(cep)
        end)
      end)

    Task.yield_many(tasks, 5000)
  end

  def main(_) do
    run()
  end
end
