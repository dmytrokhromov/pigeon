defmodule Pigeon.FCM.Error do
  @moduledoc false

  alias Pigeon.FCM.Notification

  @doc false
  @spec parse(map) :: Notification.error_response()
  def parse(%{"status" => "NOT_FOUND", "details" => details}) when is_list(details) do
    details
    |> Enum.reduce(nil, fn
      %{"@type" => "type.googleapis.com/google.firebase.fcm.v1.FcmError", "errorCode" => code}, _ -> code
      _, acc -> acc
    end)
    |> parse_response()
  end

  def parse(error) do
    error
    |> Map.get("status")
    |> parse_response()
  end

  defp parse_response("UNSPECIFIED_ERROR"), do: :unspecified_error
  defp parse_response("INVALID_ARGUMENT"), do: :invalid_argument
  defp parse_response("UNREGISTERED"), do: :unregistered
  defp parse_response("SENDER_ID_MISMATCH"), do: :sender_id_mismatch
  defp parse_response("QUOTA_EXCEEDED"), do: :quota_exceeded
  defp parse_response("UNAVAILABLE"), do: :unavailable
  defp parse_response("INTERNAL"), do: :internal
  defp parse_response("THIRD_PARTY_AUTH_ERROR"), do: :third_party_auth_error
  defp parse_response(_), do: :unknown_error
end
