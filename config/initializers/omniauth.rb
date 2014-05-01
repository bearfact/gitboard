GITHUB_CONFIG = YAML.load_file("#{::Rails.root}/config/github.yml")[::Rails.env]


OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, GITHUB_CONFIG['key'], GITHUB_CONFIG['secret'], scope: "repo"
end
