defmodule Test do
  def perform(url) do
    case :hackney.request(:get, url, [], "", download_options()) do
      {:ok, 200, _, reference} ->
        case :hackney.body(reference) do
          {:ok, _body} -> {:ok, "All good!"}
          {:error, reason} -> {:error, reason}
        end

      response ->
        {:error, """
        - URL: #{url}
        - Error (hackney response):
        #{inspect(response)}
        """}
    end
  end

  defp download_options do
    options = [
      ssl_options:
        [
          # verify: :verify_none, # Don't use this
          verify: :verify_peer,
          cacertfile: "priv/cacert.pem",
          depth: 4,
          ciphers: ciphers(),
          honor_cipher_order: :undefined
        ] ++ customize_hostname_check_or_verify_fun()
    ]
    IO.puts "=============================="
    IO.puts "!!! Hackney options for OTP #{System.otp_release()}"
    IO.inspect options
    IO.puts "=============================="

    options
  end

  if System.otp_release() >= "20.3" do
    defp ciphers, do: :ssl.cipher_suites(:default, :"tlsv1.2")
  else
    defp ciphers, do: :ssl.cipher_suites()
  end

  if System.otp_release() >= "21" do
    defp customize_hostname_check_or_verify_fun do
      [
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    end
  else
    defp customize_hostname_check_or_verify_fun do
      [
        verify_fun:
          {fn
             _, :valid, state -> {:valid, state}
             _, :valid_peer, state -> {:valid, state}
             _, {:extension, _}, state -> {:unknown, state}
             _, reason, _ -> {:fail, reason}
           end, self()}
      ]
    end
  end

  def handle_result({:ok, message}) do
    IO.puts "Success"
    IO.puts message
  end

  def handle_result({:error, message}) do
    IO.puts "Failure"
    IO.puts message
  end
end

# IO.puts "-------------------------------------------------------------"
# IO.puts "Fastly"
# Test.handle_result Test.perform("https://appsignal-agent-releases.global.ssl.fastly.net/7376537/appsignal-x86_64-linux-all-static.tar.gz")

IO.puts "-------------------------------------------------------------"
IO.puts "Cloudfront"
Test.handle_result Test.perform("https://d135dj0rjqvssy.cloudfront.net/7376537/appsignal-x86_64-linux-all-static.tar.gz")
