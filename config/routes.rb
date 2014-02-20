Support::Engine.routes.draw do
  get "/" => "support#index"
  get "/topics" => "support#topics"
  get "/topics/:topic" => "support#show_topic"
  get "*path" => "support#permalink"
end
