# frozen_string_literal: true

Pay::Engine.routes.draw do
  resources :payments, only: [:show], module: :pay
  post "webhooks/stripe", to: "pay/webhooks/stripe#create"
  post "webhooks/braintree", to: "pay/webhooks/braintree#create"
  post "webhooks/paddle", to: "pay/webhooks/paddle#create"
  
  ##accept webhoks
  get "webhooks/accept", to: "pay/webhooks/accept#charge_response"
  post "webhooks/accept", to: "pay/webhooks/accept#charge_callback"
end
