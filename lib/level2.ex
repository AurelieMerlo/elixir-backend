defmodule Level2 do

  def prices_per_worker(data_file, output_file) do
    data_file
    |> File.read!()
    |> JSON.decode!()
    |> calculate_prices
    |> generate_result(output_file)
  end

  defp calculate_prices(%{ "workers" => workers, "shifts" => shifts }) do
    prices = Enum.map workers, fn worker ->
      %{"id" => worker["id"], "price" => calculated_price(worker["id"], worker["status"], shifts)}
    end

    result = %{"workers" => prices}
             |> JSON.encode!()

    result
  end

  defp calculated_price(id, status, shifts) do
    worker_shifts = Enum.filter shifts, fn shift ->
                      shift["user_id"] == id
                    end

    shifts_count = Enum.count(worker_shifts) 

    shifts_count * price_per_status(status)
  end

  defp price_per_status(status) do
    case status do
      "medic" -> 270
      "interne" -> 126
    end
  end

  defp generate_result(result, output_file) do
    File.write!(output_file, result)
  end

end


# Level2.prices_per_worker("./files/data_level2.json", "../output.json")