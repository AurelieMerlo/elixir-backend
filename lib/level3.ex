defmodule Level3 do

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

    shifts_count(worker_shifts) * price_per_status(status)
  end

  defp price_per_status(status) do
    case status do
      "medic" -> 270
      "interne" -> 126
    end
  end

  defp parse_date(date) do
    [year, month, day] = String.split(date, "-")

    {year, _r} = Integer.parse(year)
    {month, _r} = Integer.parse(month)
    {day, _r} = Integer.parse(day)

    {:ok, date} = Date.new(year, month, day)

    date
  end

  defp is_weekday?(date) do
    date
    |> parse_date
    |> Date.day_of_week() > 5
  end

  defp shifts_count(worker_shifts) do
    Enum.reduce(worker_shifts, 0, fn worker_shift, acc  ->
      if is_weekday?(worker_shift["start_date"]), do: acc + 2, else: acc + 1
    end)
  end

  defp generate_result(result, output_file) do
    File.write!(output_file, result)
  end

end


# Level3.prices_per_worker("./files/data_level3.json", "../output.json")