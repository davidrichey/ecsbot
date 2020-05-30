use Mix.Config

config :ecsbot,
  slack_api_key: "SLACK_API_KEY",
  aws_bucket: "test.ecsbot"

config :ex_aws,
  access_key_id: ["AWS_KEY", :instance_role],
  secret_access_key: ["AWS_SECRECT", :instance_role]

config :ecsbot, :aws,
  service: Mocks.AWS.Service,
  task_definition: Mocks.AWS.TaskDefinition
