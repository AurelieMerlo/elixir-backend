defmodule Level4 do

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

    commission = %{"pdg_fee" => calculate_pdg_fee(workers, shifts), "interim_shifts" => calculate_interim_shifts(workers, shifts)}

    %{"workers" => prices, "commission" => commission} |> JSON.encode!()
  end

  defp calculated_price(id, status, shifts) do
    shifts_count(worker_shifts(id, shifts)) * price_per_status(status)
  end

  defp shifts_count(worker_shifts) do
    Enum.reduce(worker_shifts, 0, fn worker_shift, acc  ->
      if is_weekday?(worker_shift["start_date"]), do: acc + 2, else: acc + 1
    end)
  end

  defp worker_shifts(id, shifts) do
    Enum.filter shifts, fn shift ->
      shift["user_id"] == id
    end
  end

  defp price_per_status(status) do
    case status do
      "medic" -> 270
      "interne" -> 126
      "interim" -> 480
    end
  end

  defp calculate_pdg_fee(workers, shifts) do    
    calculate_interim_shifts(workers, shifts) * 80 + other_workers_fee(workers, shifts)
  end

  defp other_workers_fee(workers, shifts) do
    Enum.reduce(workers, 0, fn worker, acc  ->
      acc + calculated_price(worker["id"], worker["status"], shifts) * 0.05
    end)
  end

  defp calculate_interim_shifts(workers, shifts) do
    interim_workers = Enum.filter workers, fn worker ->
      worker["status"] == "interim"
    end

    interim_shifts = Enum.map interim_workers, fn interim_worker ->
      worker_shifts(interim_worker["id"], shifts)
    end

    List.flatten(interim_shifts) |> Enum.count()
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

  defp generate_result(result, output_file) do
    File.write!(output_file, result)
  end

end


# Level4.prices_per_worker("./files/data_level4.json", "../output.json")
