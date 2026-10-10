require "json"
require "sinatra/base"
require_relative "../account_profiles"
require_relative "../db"
require_relative "../presenters/broker_attribution_presenter"
require_relative "../presenters/broker_campaign_presenter"
require_relative "../presenters/broker_report_presenter"
require_relative "../presenters/conditional_order_presenter"
require_relative "../presenters/ledger_presenter"
require_relative "../presenters/market_data_presenter"
require_relative "../presenters/market_presenter"
require_relative "../presenters/order_presenter"
require_relative "../presenters/public_feed_event_presenter"
require_relative "../presenters/rfq_presenter"
require_relative "../presenters/rfq_quote_presenter"
require_relative "../presenters/session_presenter"
require_relative "../presenters/trade_presenter"
require_relative "../presenters/trade_receipt_presenter"
require_relative "../presenters/user_presenter"
require_relative "../presenters/wallet_presenter"
require_relative "../repositories/ledger_repository"
require_relative "../repositories/market_repository"
require_relative "../repositories/public_feed_repository"
require_relative "../repositories/session_repository"
require_relative "../repositories/user_repository"
require_relative "../repositories/wallet_repository"
require_relative "../services/faucet_service"
require_relative "../services/broker_service"
require_relative "../services/broker_report_service"
require_relative "../services/conditional_order_service"
require_relative "../services/market_data_service"
require_relative "../services/order_service"
require_relative "../services/rfq_service"

module VoltaX
  module Web
    class UIStatic
      ASSET_PATHS = {
        "/" => "index.html",
        "/index.html" => "index.html",
        "/main.js" => "main.js",
        "/styles.css" => "styles.css"
      }.freeze

      ASSET_TYPES = {
        ".css" => "text/css",
        ".html" => "text/html",
        ".js" => "application/javascript"
      }.freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)
        asset = ASSET_PATHS[request.path_info]
        return @app.call(env) unless asset && %w[GET HEAD].include?(request.request_method)

        root = ui_root
        return @app.call(env) unless root

        path = File.expand_path(asset, root)
        root_prefix = File.expand_path(root) + File::SEPARATOR
        return @app.call(env) unless path.start_with?(root_prefix) && File.file?(path)

        headers = {
          "content-type" => ASSET_TYPES.fetch(File.extname(path), "application/octet-stream"),
          "content-length" => File.size(path).to_s,
          "x-content-type-options" => "nosniff"
        }
        body = request.head? ? [] : [File.binread(path)]
        [200, headers, body]
      end

      private

      def ui_root
        @ui_root ||= [
          File.expand_path("../../../public", __dir__),
          File.expand_path("../../../frontend/dist", __dir__)
        ].find { |candidate| File.file?(File.join(candidate, "index.html")) }
      end
    end

    class Application < Sinatra::Base
      MAX_JSON_BYTES = 16_384
      USERNAME_PATTERN = /\A[a-zA-Z0-9_.-]{3,32}\z/.freeze
      IDEMPOTENCY_KEY_PATTERN = /\A[a-zA-Z0-9_.:-]{8,128}\z/.freeze
      PUBLIC_FEED_ROUTE = "/api/" + "feed/public"

      configure do
        use UIStatic
        disable :logging
        disable :method_override
        disable :sessions
        disable :show_exceptions
        disable :static
        set :raise_errors, false
      end

      before do
        content_type :json
      end

      get "/health" do
        json(status: "ok", service: configuration.service_name)
      end

      get "/ready" do
        payload, http_status = readiness_status
        status http_status
        json(payload)
      end

      post "/api/auth/register" do
        payload = json_body
        username = valid_username(payload["username"])
        password = valid_password(payload["password"])
        account_profile = payload.key?("account_profile") ? payload["account_profile"] : "spot"

        with_database do |database|
          user = user_repository(database).create(username: username, password: password, account_profile: account_profile)
          session_result = session_repository(database).create(user_id: user[:id])

          status 201
          json(
            user: Presenters::UserPresenter.render(user),
            session: Presenters::SessionPresenter.render_created(
              session: session_result[:session],
              token: session_result[:token]
            )
          )
        end
      rescue Sequel::UniqueConstraintViolation
        halt_json 409, error: "username_taken"
      rescue ArgumentError
        halt_json 400, error: "invalid_request"
      end

      post "/api/auth/login" do
        payload = json_body
        username = valid_username(payload["username"])
        password = valid_password(payload["password"])

        with_database do |database|
          users = user_repository(database)
          user = users.find_by_username(username)
          halt_json 401, error: "unauthorized" unless user && user[:status] == "active"
          halt_json 401, error: "unauthorized" unless users.password_valid?(user, password)

          session_result = session_repository(database).create(user_id: user[:id])

          json(
            user: Presenters::UserPresenter.render(user),
            session: Presenters::SessionPresenter.render_created(
              session: session_result[:session],
              token: session_result[:token]
            )
          )
        end
      rescue ArgumentError
        halt_json 400, error: "invalid_request"
      end

      get "/api/auth/me" do
        with_database do |database|
          session, user = authenticated_session_and_user(database)

          json(
            user: Presenters::UserPresenter.render(user),
            session: Presenters::SessionPresenter.render_current(session)
          )
        end
      end

      get "/api/markets" do
        with_database do |database|
          VoltaX::DB.seed_markets(database: database)
          markets = market_repository(database).list

          json(markets: markets.map { |market| Presenters::MarketPresenter.render(market) })
        end
      end

      get PUBLIC_FEED_ROUTE do
        with_database do |database|
          market_symbol = params["market_symbol"] || params["market"]
          since_sequence = params["since_sequence"] || params["after_sequence"] || 0
          limit = params["limit"] || Repositories::PublicFeedRepository::DEFAULT_LIMIT
          repository = public_feed_repository(database)
          events = repository.list(
            market_symbol: market_symbol,
            since_sequence: since_sequence,
            limit: limit
          )
          tail_sequence = repository.tail_sequence(market_symbol: market_symbol)

          json(
            events: events.map do |event|
              Presenters::PublicFeedEventPresenter.render(event)
            end,
            next_sequence: tail_sequence + 1
          )
        end
      rescue ArgumentError
        halt_json 400, error: "invalid_request"
      end

      post "/api/faucet" do
        payload = json_body
        idempotency_key = valid_idempotency_key(payload["idempotency_key"])

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          result = Services::FaucetService.new(database: database).claim(
            user_id: user[:id],
            idempotency_key: idempotency_key
          )

          status(result[:funded] ? 201 : 200)
          json(
            faucet: {
              status: result[:funded] ? "funded" : "already_funded",
              replayed: result[:replayed]
            },
            wallets: result[:wallets].map { |wallet| Presenters::WalletPresenter.render(wallet) },
            ledger_entries: result[:ledger_entries].map { |entry| Presenters::LedgerPresenter.render(entry) }
          )
        end
      rescue Services::FaucetService::AlreadyClaimed
        halt_json 409, error: "faucet_already_claimed"
      rescue ArgumentError
        halt_json 400, error: "invalid_request"
      end

      get "/api/wallets" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          wallets = wallet_repository(database).list_for_user(user_id: user[:id])

          json(wallets: wallets.map { |wallet| Presenters::WalletPresenter.render(wallet) })
        end
      end

      get "/api/ledger" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          entries = ledger_repository(database).list_for_user(user_id: user[:id])

          json(ledger_entries: entries.map { |entry| Presenters::LedgerPresenter.render(entry) })
        end
      end

      get "/api/users/me/trades" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          rows = market_data_service(database).user_trades(user: user)

          json(trades: rows.map { |row| Presenters::MarketDataPresenter.render_user_trade(row) })
        end
      end

      post "/api/orders" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          halt_json 403, error: "forbidden" unless AccountProfiles.can?(user, "orders")
          VoltaX::DB.seed_markets(database: database)
          order = order_service(database).place(
            user_id: user[:id],
            market_symbol: payload["market_symbol"],
            side: payload["side"],
            order_type: payload.fetch("order_type", payload.fetch("type", "limit")),
            limit_price: payload["limit_price"],
            quantity: payload.fetch("quantity", payload["original_quantity"]),
            client_order_id: payload["client_order_id"],
            execution_memo: payload["execution_memo"],
            booking_ref: payload["booking_ref"]
          )

          status 201
          json(order: Presenters::OrderPresenter.render(order, market_symbol: payload["market_symbol"].to_s))
        end
      rescue Services::OrderService::InsufficientFunds
        halt_json 409, error: "insufficient_funds"
      rescue Services::OrderService::ClientOrderIdTaken
        halt_json 409, error: "client_order_id_taken"
      rescue Services::OrderService::InvalidRequest, KeyError
        halt_json 400, error: "invalid_request"
      end

      get "/api/orders" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          halt_json 403, error: "forbidden" unless AccountProfiles.can?(user, "orders")
          orders = order_service(database).list_for_user(user_id: user[:id])

          json(
            orders: orders.map do |order, market_symbol|
              Presenters::OrderPresenter.render(order, market_symbol: market_symbol)
            end
          )
        end
      end

      get "/api/orders/lookup/:reference_code" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          halt_json 403, error: "forbidden" unless AccountProfiles.can?(user, "orders")
          order, market_symbol = order_service(database).resolve_order_reference(
            account: user,
            reference_code: params[:reference_code]
          )

          json(order: Presenters::OrderPresenter.render_reference(order, market_symbol: market_symbol))
        end
      rescue Services::OrderService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::OrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/orders/:order_id" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          halt_json 403, error: "forbidden" unless AccountProfiles.can?(user, "orders")
          order, market_symbol = order_service(database).find_for_user(user_id: user[:id], order_id: params[:order_id])

          json(order: Presenters::OrderPresenter.render(order, market_symbol: market_symbol))
        end
      rescue Services::OrderService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::OrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      delete "/api/orders/:order_id" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          halt_json 403, error: "forbidden" unless AccountProfiles.can?(user, "orders")
          order, market_symbol = order_service(database).cancel(user_id: user[:id], order_id: params[:order_id])

          json(order: Presenters::OrderPresenter.render(order, market_symbol: market_symbol))
        end
      rescue Services::OrderService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::OrderService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::OrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/markets/:symbol/orderbook" do
        with_database do |database|
          VoltaX::DB.seed_markets(database: database)
          book = order_service(database).orderbook(market_symbol: params[:symbol], depth: params["depth"])

          json(orderbook: Presenters::OrderPresenter.render_book(**book))
        end
      rescue Services::OrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/markets/:symbol/ticker" do
        with_database do |database|
          VoltaX::DB.seed_markets(database: database)
          ticker = market_data_service(database).ticker(market_symbol: params[:symbol])

          json(ticker: Presenters::MarketDataPresenter.render_ticker(ticker))
        end
      rescue Services::MarketDataService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/markets/:symbol/candles" do
        with_database do |database|
          VoltaX::DB.seed_markets(database: database)
          candles = market_data_service(database).candles(
            market_symbol: params[:symbol],
            interval: params["interval"] || "1m",
            limit: params["limit"] || Services::MarketDataService::DEFAULT_LIMIT
          )

          json(candles: candles.map { |candle| Presenters::MarketDataPresenter.render_candle(candle) })
        end
      rescue Services::MarketDataService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/markets/:symbol/trades" do
        with_database do |database|
          VoltaX::DB.seed_markets(database: database)
          trades = order_service(database).trades_for_market(market_symbol: params[:symbol])

          json(
            trades: trades.map do |trade, market_symbol|
              Presenters::TradePresenter.render(trade, market_symbol: market_symbol)
            end
          )
        end
      rescue Services::OrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/trades/:trade_id/receipt" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          receipt = order_service(database).receipt_for_user(user_id: user[:id], trade_id: params[:trade_id])

          json(receipt: Presenters::TradeReceiptPresenter.render(receipt))
        end
      rescue Services::OrderService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::OrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/trades/:trade_id" do
        with_database do |database|
          service = order_service(database)
          if bearer_token
            _session, user = authenticated_session_and_user(database)
            rendered = participant_trade_detail_response(
              service: service,
              user_id: user[:id],
              trade_id: params[:trade_id]
            )

            json(trade: rendered)
          else
            trade, market_symbol = service.public_trade(trade_id: params[:trade_id])

            json(trade: Presenters::TradePresenter.render(trade, market_symbol: market_symbol))
          end
        end
      rescue Services::OrderService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::OrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      post "/api/rfq" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          VoltaX::DB.seed_markets(database: database)
          rfq, market_symbol, quotes = rfq_service(database).create(
            user: user,
            market_symbol: payload["market_symbol"],
            side: payload["side"],
            quantity: payload["quantity"],
            target_price: payload["target_price"],
            public_comment: payload["public_comment"],
            delivery_terms: payload["delivery_terms"],
            expires_at: payload["expires_at"]
          )

          status 201
          json(
            rfq: Presenters::RFQPresenter.render_owner(
              rfq,
              market_symbol: market_symbol,
              quotes: quotes.map { |quote| Presenters::RFQQuotePresenter.render_owner(quote) }
            )
          )
        end
      rescue Services::RFQService::InvalidRequest, KeyError
        halt_json 400, error: "invalid_request"
      end

      get "/api/rfq/board" do
        with_database do |database|
          authenticated_session_and_user(database)
          VoltaX::DB.seed_markets(database: database)
          rows = rfq_service(database).board

          json(rfqs: rows.map { |row| Presenters::RFQPresenter.render_board(row) })
        end
      end

      get "/api/rfq/:rfq_id/workup" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          workup = rfq_service(database).quote_workup_for(
            account: user,
            rfq_id: params[:rfq_id]
          )

          json(rfq: Presenters::RFQPresenter.render_workup(workup))
        end
      rescue Services::RFQService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::RFQService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::RFQService::QuoteNotAcceptable
        halt_json 409, error: "quote_not_acceptable"
      rescue Services::RFQService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      post "/api/rfq/:rfq_id/quote" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          quote = rfq_service(database).submit_quote(
            user: user,
            rfq_id: params[:rfq_id],
            price: payload["price"],
            quantity: payload["quantity"],
            expires_at: payload["expires_at"]
          )

          status 201
          json(quote: Presenters::RFQQuotePresenter.render_maker(quote))
        end
      rescue Services::RFQService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::RFQService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::RFQService::RFQNotOpen
        halt_json 409, error: "rfq_not_open"
      rescue Services::RFQService::QuoteAlreadyExists
        halt_json 409, error: "quote_already_exists"
      rescue Services::RFQService::InvalidRequest, KeyError
        halt_json 400, error: "invalid_request"
      end

      post "/api/rfq/:rfq_id/accept" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          quote, owner_view, trade = rfq_service(database).accept_quote(
            user: user,
            rfq_id: params[:rfq_id],
            quote_id: payload["quote_id"]
          )
          rfq, market_symbol, quotes = owner_view

          json(
            quote: Presenters::RFQQuotePresenter.render_owner(quote),
            trade: Presenters::TradePresenter.render(trade, market_symbol: market_symbol),
            rfq: Presenters::RFQPresenter.render_owner(
              rfq,
              market_symbol: market_symbol,
              quotes: quotes.map { |owner_quote| Presenters::RFQQuotePresenter.render_owner(owner_quote) }
            )
          )
        end
      rescue Services::RFQService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::RFQService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::RFQService::RFQNotOpen
        halt_json 409, error: "rfq_not_open"
      rescue Services::RFQService::QuoteNotAcceptable
        halt_json 409, error: "quote_not_acceptable"
      rescue Services::RFQService::InsufficientFunds
        halt_json 409, error: "insufficient_funds"
      rescue Services::RFQService::InvalidRequest, KeyError
        halt_json 400, error: "invalid_request"
      end

      post "/api/rfq/:rfq_id/simulate-settlement" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          simulation = rfq_service(database).simulate_settlement(
            user: user,
            rfq_id: params[:rfq_id],
            quote_id: payload["quote_id"]
          )

          json(simulation: Presenters::RFQPresenter.render_settlement_simulation(simulation))
        end
      rescue Services::RFQService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::RFQService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::RFQService::QuoteNotAcceptable
        halt_json 409, error: "quote_not_acceptable"
      rescue Services::RFQService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/rfq/:rfq_id/accepted-counterparty" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          view = rfq_service(database).accepted_counterparty(user: user, rfq_id: params[:rfq_id])

          json(rfq: Presenters::RFQPresenter.render_accepted_counterparty(view))
        end
      rescue Services::RFQService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::RFQService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::RFQService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/rfq/:rfq_id" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          rfq, market_symbol, quotes = rfq_service(database).owner_detail(user: user, rfq_id: params[:rfq_id])

          json(
            rfq: Presenters::RFQPresenter.render_owner(
              rfq,
              market_symbol: market_symbol,
              quotes: quotes.map { |quote| Presenters::RFQQuotePresenter.render_owner(quote) }
            )
          )
        end
      rescue Services::RFQService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::RFQService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      post "/api/broker/campaigns" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          campaign = broker_service(database).create_campaign(
            user: user,
            campaign_code: payload["campaign_code"],
            name: payload["name"],
            starts_at: payload["starts_at"],
            ends_at: payload["ends_at"]
          )

          status 201
          json(campaign: Presenters::BrokerCampaignPresenter.render(campaign))
        end
      rescue Services::BrokerService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::BrokerService::CampaignCodeTaken
        halt_json 409, error: "campaign_code_taken"
      rescue Services::BrokerService::InvalidRequest, KeyError
        halt_json 400, error: "invalid_request"
      end

      get "/api/broker/campaigns" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          campaigns = broker_service(database).list_campaigns(user: user)

          json(campaigns: campaigns.map { |campaign| Presenters::BrokerCampaignPresenter.render(campaign) })
        end
      rescue Services::BrokerService::Forbidden
        halt_json 403, error: "forbidden"
      end

      post "/api/broker/attributions" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          attribution, campaign = broker_service(database).create_attribution(user: user, payload: payload)

          status 201
          json(attribution: Presenters::BrokerAttributionPresenter.render(attribution, campaign: campaign))
        end
      rescue Services::BrokerService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::BrokerService::CampaignNotActive
        halt_json 409, error: "campaign_not_active"
      rescue Services::BrokerService::AttributionAlreadyExists
        halt_json 409, error: "attribution_already_exists"
      rescue Services::BrokerService::InvalidRequest, KeyError
        halt_json 400, error: "invalid_request"
      end

      get "/api/broker/reports/trades" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          rows = broker_report_service(database).trade_rows(
            user: user,
            month: params["month"],
            campaign_id: params["campaign_id"]
          )

          json(
            trades: rows.map do |row|
              Presenters::BrokerReportPresenter.render_trade(row)
            end
          )
        end
      rescue Services::BrokerReportService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::BrokerReportService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      get "/api/broker/reports/monthly" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          rows = broker_report_service(database).monthly_rows(
            user: user,
            month: params["month"],
            campaign_id: params["campaign_id"]
          )

          json(monthly: rows.map { |row| Presenters::BrokerReportPresenter.render_monthly(row) })
        end
      rescue Services::BrokerReportService::Forbidden
        halt_json 403, error: "forbidden"
      rescue Services::BrokerReportService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      post "/api/conditional-orders" do
        payload = json_body

        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          VoltaX::DB.seed_markets(database: database)
          order, market_symbol = conditional_order_service(database).create(
            user: user,
            market_symbol: payload["market_symbol"],
            side: payload["side"],
            trigger_type: payload["trigger_type"],
            trigger_price: payload["trigger_price"],
            limit_price: payload["limit_price"],
            quantity: payload["quantity"],
            client_order_id: payload["client_order_id"],
            signal_context: payload["signal_context"],
            expires_at: payload["expires_at"]
          )

          status 201
          json(conditional_order: Presenters::ConditionalOrderPresenter.render_owner(order, market_symbol: market_symbol))
        end
      rescue Services::ConditionalOrderService::ClientOrderIdTaken
        halt_json 409, error: "client_order_id_taken"
      rescue Services::ConditionalOrderService::InvalidRequest, KeyError
        halt_json 400, error: "invalid_request"
      end

      get "/api/conditional-orders" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          rows = conditional_order_service(database).list_for_owner(user: user)

          json(
            conditional_orders: rows.map do |order, market_symbol|
              Presenters::ConditionalOrderPresenter.render_owner(order, market_symbol: market_symbol)
            end
          )
        end
      end

      get "/api/conditional-orders/:conditional_order_id" do
        with_database do |database|
          _session, user = authenticated_session_and_user(database)
          order, market_symbol = conditional_order_service(database).owner_detail(
            user: user,
            conditional_order_id: params[:conditional_order_id]
          )

          json(conditional_order: Presenters::ConditionalOrderPresenter.render_owner(order, market_symbol: market_symbol))
        end
      rescue Services::ConditionalOrderService::NotFound
        halt_json 404, error: "not_found"
      rescue Services::ConditionalOrderService::InvalidRequest
        halt_json 400, error: "invalid_request"
      end

      not_found do
        status 404
        json(error: "not_found")
      end

      error do
        status 500
        json(error: "internal_error")
      end

      def self.for_configuration(configuration)
        Class.new(self) do
          set :voltax_configuration, configuration
        end
      end

      private

      def configuration
        settings.voltax_configuration
      end

      def json(payload)
        JSON.generate(payload)
      end

      def json_body
        request.body.rewind
        body = request.body.read(MAX_JSON_BYTES + 1).to_s
        halt_json 413, error: "request_too_large" if body.bytesize > MAX_JSON_BYTES

        payload = JSON.parse(body)
        halt_json 400, error: "invalid_request" unless payload.is_a?(Hash)

        payload
      rescue JSON::ParserError
        halt_json 400, error: "invalid_json"
      end

      def valid_username(value)
        username = value.to_s
        raise ArgumentError unless username.match?(USERNAME_PATTERN)

        username
      end

      def valid_password(value)
        raise ArgumentError unless value.is_a?(String)
        raise ArgumentError if value.length < Auth::Password::MIN_LENGTH

        value
      end

      def valid_idempotency_key(value)
        raise ArgumentError unless value.is_a?(String)
        raise ArgumentError unless value.match?(IDEMPOTENCY_KEY_PATTERN)

        value
      end

      def participant_trade_detail_response(service:, user_id:, trade_id:)
        trade, market_symbol, receipt, booking_rows = service.participant_trade_detail(
          user_id: user_id,
          trade_id: trade_id
        )
        Presenters::TradePresenter.render_participant_detail(
          trade,
          market_symbol: market_symbol,
          receipt: receipt,
          booking_rows: booking_rows
        )
      end

      def bearer_token
        header = request.env["HTTP_AUTHORIZATION"].to_s
        match = header.match(/\ABearer ([A-Za-z0-9_\-]+=*)\z/)
        match && match[1]
      end

      def authenticated_session(database)
        token = bearer_token
        halt_json 401, error: "unauthorized" unless token

        session = session_repository(database).find_by_token(token)
        halt_json 401, error: "unauthorized" unless session

        session
      end

      def authenticated_session_and_user(database)
        session = authenticated_session(database)
        user = user_repository(database).find_by_id(session[:user_id])
        halt_json 401, error: "unauthorized" unless user && user[:status] == "active"

        [session, user]
      end

      def with_database
        database = VoltaX::DB.connect(configuration: configuration)
        yield database
      rescue VoltaX::DB::ConnectionError
        halt_json 503, error: "service_unavailable"
      ensure
        database&.disconnect
      end

      def readiness_status
        checks = { boot: "ok" }
        return [{ status: "ready", service: configuration.service_name, checks: checks }, 200] unless configuration.database_url

        database = VoltaX::DB.connect(configuration: configuration)
        database.fetch("SELECT 1 AS ok").first
        migration_version = VoltaX::DB.current_version(database: database)
        checks[:postgres] = "ok"
        checks[:migrations] = migration_version ? "applied" : "missing"
        ready = checks[:migrations] == "applied"

        [{ status: ready ? "ready" : "not_ready", service: configuration.service_name, checks: checks }, ready ? 200 : 503]
      rescue VoltaX::DB::ConnectionError
        checks[:postgres] = "unavailable"
        checks[:migrations] = "unknown"
        [{ status: "not_ready", service: configuration.service_name, checks: checks }, 503]
      ensure
        database&.disconnect
      end

      def user_repository(database)
        Repositories::UserRepository.new(database: database, environment: configuration.environment)
      end

      def session_repository(database)
        Repositories::SessionRepository.new(database: database, credential_key_base: credential_key_base)
      end

      def market_repository(database)
        Repositories::MarketRepository.new(database: database)
      end

      def public_feed_repository(database)
        Repositories::PublicFeedRepository.new(database: database)
      end

      def wallet_repository(database)
        Repositories::WalletRepository.new(database: database)
      end

      def ledger_repository(database)
        Repositories::LedgerRepository.new(database: database)
      end

      def order_service(database)
        Services::OrderService.new(database: database)
      end

      def market_data_service(database)
        Services::MarketDataService.new(database: database)
      end

      def rfq_service(database)
        Services::RFQService.new(database: database)
      end

      def broker_service(database)
        Services::BrokerService.new(database: database)
      end

      def broker_report_service(database)
        Services::BrokerReportService.new(database: database)
      end

      def conditional_order_service(database)
        Services::ConditionalOrderService.new(database: database)
      end

      def credential_key_base
        configuration.instance_variable_get(:@credential_key_base)
      end

      def halt_json(status_code, payload)
        status status_code
        halt json(payload)
      end
    end
  end
end
