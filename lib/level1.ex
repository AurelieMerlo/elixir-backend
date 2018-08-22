defmodule Level1 do

  def prices_per_worker(data_file, output_file) do
    data_file
    |> File.read!()
    |> JSON.decode!()
    |> calculate_prices
    |> generate_result(output_file)
  end

  defp calculate_prices(%{ "workers" => workers, "shifts" => shifts }) do
    prices = Enum.map workers, fn worker ->
      %{"id" => worker["id"], "price" => calculated_price(worker["id"], worker["price_per_shift"], shifts)}
    end

    result = %{"workers" => prices}
             |> JSON.encode!()

    result
  end

  defp calculated_price(id, price_per_shift, shifts) do
    worker_shifts = Enum.filter shifts, fn shift ->
                      shift["user_id"] == id
                    end

    shifts_count = Enum.count(worker_shifts) 

    shifts_count * price_per_shift
  end

  defp generate_result(result, output_file) do
    File.write!(output_file, result)
  end

end


# Level1.prices_per_worker("./files/data_level1.json", "../output.json")