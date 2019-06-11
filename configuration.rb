VCR.configure do |config|
  config.before_record do |interaction|
    interaction.request.headers.delete("Authorization")
  end

  config.cassette_library_dir = "cache"
  config.hook_into :webmock
end

Proxy::Configuration.configure do |config|
  config.base_url     = "https://tessituradev.sheddaquarium.hq/Dev/TessituraService"
  config.http_options = {verify_mode: OpenSSL::SSL::VERIFY_NONE}
end
