import Config
port = String.to_integer(System.get_env("PORT") || "4000")

config :pleroma, Pleroma.Web.Endpoint,
  url: [host: System.get_env("DOMAIN", "localhost"), scheme: "https", port: 443],
  http: [ip: {0, 0, 0, 0}, port: port]

config :pleroma, Pleroma.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10

config :pleroma, :instance,
  name: "tmg.freestateranch.com",
  email: "alexg@dbadbadba.com",
  notify_email: "alexg@dbadbadba.com",
  limit: 5000,
  registrations_open: true

config :pleroma, configurable_from_database: true

# Configure S3 support if desired.
# The public S3 endpoint (base_url) is different depending on region and provider,
# consult your S3 provider's documentation for details on what to use.
#
config :pleroma, Pleroma.Upload,
  uploader: Pleroma.Uploaders.S3,
  base_url: "https://s3.amazonaws.com"

config :pleroma, Pleroma.Uploaders.S3,
  bucket: System.get_env("AWS_BUCKET"),
  bucket_namespace: nil,
  truncated_namespace: nil,
  streaming_enabled: true

# Configure S3 credentials:
config :ex_aws, :s3,
  access_key_id: System.get_env("AWS_ACCESS_KEY"),
  secret_access_key: System.get_env("AWS_ACCESS_SECRET"),
  region: System.get_env("AWS_REGION"),
  scheme: "https://"

# For using third-party S3 clones like wasabi, also do:
# config :ex_aws, :s3, host: "s3.wasabisys.com"

config :pleroma, Pleroma.Upload,
  filters: [Pleroma.Upload.Filter.Exiftool, Pleroma.Upload.Filter.AnonymizeFilename]

config :prometheus, Pleroma.Web.Endpoint.MetricsExporter,
  enabled: true,
  path: "/api/metrics",
  auth: false

# PromEx set up
config :pleroma, Pleroma.Web.Plugs.MetricsPredicate,
  auth_token: System.fetch_env!("PROMETHEUS_AUTH_TOKEN")

config :pleroma, Pleroma.PromEx,
  prometheus_data_source_id: System.fetch_env!("PROMETHEUS_DATASOURCE_ID"),
  grafana: [
    host: System.fetch_env!("GRAFANA_HOST"),
    auth_token: System.fetch_env!("GRAFANA_AUTH_TOKEN"),
    upload_dashboards_on_start: true,
    folder_name: "Pleroma - PromEx",
    annotate_app_lifecycle: true
  ]

config :sentry,
  dsn: System.fetch_env!("SENTRY_DSN"),
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]
