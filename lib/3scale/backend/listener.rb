require '3scale/backend/version'
require 'json'

module ThreeScale
  module Backend
    class Listener < Sinatra::Base
      disable :logging
      enable :raise_errors
      disable :show_exceptions

      ## ------------ DOCS --------------
      ##~ sapi = source2swagger.namespace("Service Management API")
      ##~ sapi.basePath = "https://su1.3scale.net"
      ##~ sapi.swaggerVersion = "0.1a"
      ##~ sapi.apiVersion = "1.0"
      ##
      ## ------------ DOCS COMMON -------
      ##~ @parameter_provider_key = {"name" => "provider_key", "dataType" => "string", "required" => true, "paramType" => "query", "threescale_name" => "api_keys"}
      ##~ @parameter_provider_key["description"] = "Your api key with 3scale (also known as provider key)."
      ##
      ##~ @parameter_service_id = {"name" => "service_id", "dataType" => "string", "paramType" => "query", "threescale_name" => "service_ids"}
      ##~ @parameter_service_id["description"] = "Service id. Required only if you have more than one service."
      ##
      ##~ @parameter_app_id = {"name" => "app_id", "dataType" => "string", "required" => true, "paramType" => "query", "threescale_name" => "app_ids"}
      ##~ @parameter_app_id["description"] = "App Id (identifier of the application if the auth. pattern is App Id)"
      ##~ @parameter_app_id_inline = @parameter_app_id.clone
      ##~ @parameter_app_id_inline["description_inline"] = true
      ##
      ##~ @parameter_access_token = {"name" => "access_token", "dataType" => "string", "required" => false, "paramType" => "query", "threescale_name" => "access_tokens"}
      ##~ @parameter_access_token["description"] = "OAuth token used for authorizing if you don't use client_id with client_secret."
      ##
      ##~ @parameter_client_id = {"name" => "app_id", "dataType" => "string", "required" => false, "paramType" => "query", "threescale_name" => "app_ids"}
      ##~ @parameter_client_id["description"] = "Client Id (identifier of the application if the auth. pattern is OAuth, note that client_id == app_id)"
      ##~ @parameter_client_id_inline = @parameter_client_id.clone
      ##~ @parameter_client_id_inline["description_inline"] = true

      ##~ @parameter_app_key = {"name" => "app_key", "dataType" => "string", "required" => false, "paramType" => "query", "threescale_name" => "app_keys"}
      ##~ @parameter_app_key["description"] = "App Key (shared secret of the application if the authentication pattern is App Id). The app key is required if the application has one or more keys defined."
      ##
      ##~ @parameter_user_key = {"name" => "user_key", "dataType" => "string", "required" => true, "paramType" => "query", "theescale_name" => "user_keys"}
      ##~ @parameter_user_key["description"] = "User Key (identifier and shared secret of the application if the auth. pattern is Api Key)"
      ##~ @parameter_user_key_inline = @parameter_user_key.clone
      ##~ @parameter_user_key_inline["description_inline"]  = true

      ##~ @parameter_user_id = {"name" => "user_id", "dataType" => "string", "paramType" => "query"}
      ##~ @parameter_user_id["description"] = "User id. String identifying an end user. Required only when the application is rate limiting end users. The End User plans feature is not available in all 3scale plans."
      ##~ @parameter_user_id_inline = @parameter_user_id.clone
      ##~ @parameter_user_id_inline["description_inline"] = true
      ##
      ##~ @parameter_user_id_oauth = {"name" => "user_id", "dataType" => "string", "paramType" => "query"}
      ##~ @parameter_user_id_oauth["description"] = "User id. String identifying an end user. Used only when the application is rate limiting end users and the specified token is not associated to a user. The End User plans feature is not available in all 3scale plans."
      ##

      ##~ @parameter_referrer = {"name" => "referrer", "dataType" => "string", "required" => false, "paramType" => "query"}
      ##~ @parameter_referrer["description"] = "Referrer IP Address or Domain. Required only if referrer filtering is enabled. If special value '*' (wildcard) is passed, the referrer check is bypassed."
      ##
      ##~ @parameter_redirect_url = {"name" => "redirect_url", "dataType" => "string", "required" => false, "paramType" => "query"}
      ##~ @parameter_redirect_url["description"] = "Optional redirect URL for OAuth. Will be validated if sent."
      ##
      ##~ @parameter_redirect_uri = {"name" => "redirect_uri", "dataType" => "string", "required" => false, "paramType" => "query"}
      ##~ @parameter_redirect_uri["description"] = "Optional redirect URI for OAuth. This is the same as 'redirect_url', but if used you should expect a matching 'redirect_uri' response field."
      ##

      ##  FIXME: CHECK THIS ONE TOO
      ##~ @parameter_no_body = {"name" => "no_body", "dataType" => "boolean", "required" => false, "paramType" => "query"}
      ##~ @parameter_no_body["description"] = "If no_body is passed the response will not include HTTP body."

      ##~ @parameter_usage = {"name" => "usage", "dataType" => "hash", "required" => false, "paramType" => "query", "allowMultiple" => false}
      ##~ @parameter_usage["description"] = "Usage will increment the metrics with the values passed. The value can be only a positive integer (e.g. 1, 50). Reporting usage[hits]=1 will increment the hits counter by +1."
      ##
      ##~ @parameter_usage_fields = {"name" => "metric", "dataType" => "custom", "required" => false, "paramType" => "query", "allowMultiple" => true, "threescale_name" => "metric_names"}
      ##~ @parameter_usage_fields["description"] = "Metric to be reported"
      ##
      ##~ @parameter_usage["parameters"] = []
      ##~ @parameter_usage["parameters"] << @parameter_usage_fields
      ##
      ##~ @parameter_usage_predicted = {"name" => "usage", "dataType" => "hash", "required" => false, "paramType" => "query", "allowMultiple" => false}
      ##~ @parameter_usage_predicted["description"] = "Predicted Usage. Actual usage will need to be reported with a report or an authrep."
      ##
      ##~ @parameter_usage_predicted["parameters"] = []
      ##~ @parameter_usage_predicted["parameters"] << @parameter_usage_fields
      ##
      ##~ @timestamp = {"name" => "timestamp", "dataType" => "string", "required" => false, "paramType" => "query"}
      ##~ @timestamp["description"] = "If passed, it should be the time when the transaction took place. Format: YYYY-MM-DD HH:MM:SS for UTC, add -HH:MM or +HH:MM for time offset. For instance, 2011-12-30 22:15:31 -08:00"
      ##~ @timestamp["description_inline"] = true
      ##
      ##~ @parameter_log = {"name" => "log", "dataType" => "hash", "required" => false, "paramType" => "query", "allowMultiple" => false}
      ##~ @parameter_log["description"] = "Request Log allows to log the requests/responses/status_codes of your API back to 3scale to maintain a log of the latest activity on your API. Request Logs are optional and not available in all 3scale plans."
      ##
      ##~ @parameter_log_field_request = {"name" => "request", "dataType" => "string", "paramType" => "query", "description_inline" => true}
      ##~ @parameter_log_field_request["description"] = "Body of the request to your API (needs to be URL encoded). Mandatory if log is not empty. Truncated after 1KB."
      ##~ @parameter_log_field_response = {"name" => "response", "dataType" => "string", "paramType" => "query", "description_inline" => true}
      ##~ @parameter_log_field_response["description"] = "Body of the response from your API (needs to be URL encoded). Optional. Truncated after 4KB."
      ##~ @parameter_log_field_code = {"name" => "code", "dataType" => "string", "paramType" => "query", "description_inline" => true}
      ##~ @parameter_log_field_code["description"] = "Response code of the response from your API (needs to be URL encoded). Optional. Truncated after 32bytes."


      ##~ @parameter_log["parameters"] = []
      ##~ @parameter_log["parameters"] << @parameter_log_field_request
      ##~ @parameter_log["parameters"] << @parameter_log_field_response
      ##~ @parameter_log["parameters"] << @parameter_log_field_code
      ##
      ##~ @parameter_transaction_app_id = {"name" => "transactions", "dataType" => "array", "required" => true, "paramType" => "query", "allowMultiple" => true}
      ##~ @parameter_transaction_app_id["description"] = "Transactions to be reported. There is a limit of 1000 transactions to be reported on a single request."
      ##~ @parameter_transaction_app_id["parameters"] = []
      ##
      ##~ @parameter_transaction_app_id["parameters"] << @parameter_app_id_inline
      ##~ @parameter_transaction_app_id["parameters"] << @parameter_user_id_inline
      ##~ @parameter_transaction_app_id["parameters"] << @timestamp
      ##~ @parameter_transaction_app_id["parameters"] << @parameter_usage
      ##~ @parameter_transaction_app_id["parameters"] << @parameter_log

      ##~ @parameter_transaction_api_key = {"name" => "transactions", "dataType" => "array", "required" => true, "paramType" => "query", "allowMultiple" => true}
      ##~ @parameter_transaction_api_key["description"] = "Transactions to be reported. There is a limit of 1000 transactions to be reported on a single request."
      ##~ @parameter_transaction_api_key["parameters"] = []

      ##~ @parameter_transaction_api_key["parameters"] << @parameter_user_key_inline
      ##~ @parameter_transaction_api_key["parameters"] << @parameter_user_id_inline
      ##~ @parameter_transaction_api_key["parameters"] << @timestamp
      ##~ @parameter_transaction_api_key["parameters"] << @parameter_usage
      ##~ @parameter_transaction_api_key["parameters"] << @parameter_log

      ##~ @parameter_transaction_oauth = {"name" => "transactions", "dataType" => "array", "required" => true, "paramType" => "query", "allowMultiple" => true}
      ##~ @parameter_transaction_oauth["description"] = "Transactions to be reported. There is a limit of 1000 transactions to be reported on a single request."
      ##~ @parameter_transaction_oauth["parameters"] = []

      ##~ @parameter_transaction_oauth["parameters"] << @parameter_client_id_inline
      ##~ @parameter_transaction_oauth["parameters"] << @parameter_user_id_inline
      ##~ @parameter_transaction_oauth["parameters"] << @timestamp
      ##~ @parameter_transaction_oauth["parameters"] << @parameter_usage
      ##~ @parameter_transaction_oauth["parameters"] << @parameter_log


      COMMON_PARAMS = ['service_id'.freeze, 'app_id'.freeze, 'app_key'.freeze, 'user_key'.freeze, 'provider_key'.freeze].freeze

      ## ------------ DOCS --------------

      configure :production do
        disable :dump_errors
      end

      set :views, File.dirname(__FILE__) + '/views'

      register AllowMethods

      use Rack::RackExceptionCatcher

      before do
        content_type 'application/vnd.3scale-v2.0+xml'
      end

      # this is an HAProxy-specific endpoint, equivalent to
      # their '/haproxy?monitor' one, just renamed to available.
      # returning 200 here means we're up willing to take requests.
      # returning 404 makes HAProxy consider us down soon(ish),
      # taking into account that usually several HAProxies contain
      # us in their listener pool and it takes for all of them to
      # notice before no request is received.
      head '/available' do
        empty_response 200
      end

      def do_api_method(method_name)
        normalize_non_empty_keys!
        unless valid_key_and_usage_params?
          empty_response 403
          return
        end

        authorization, cached_authorization_text, cached_authorization_result = Transactor.send method_name, params[:provider_key], params

        if cached_authorization_text.nil? || cached_authorization_result.nil?
          status(authorization.authorized? ? 200 : 409)
          body(params[:no_body] ? nil : authorization.to_xml)
        else
          status(cached_authorization_result ? 200 : 409)
          body(params[:no_body] ? nil : cached_authorization_text)
        end
      rescue ThreeScale::Backend::Error => error
        begin
          ErrorStorage.store(service_id, error, response_code: 403, request: request_info)
        rescue ProviderKeyInvalid
          # This happens trying to load the service id
        ensure
          raise error
        end
      end
      private :do_api_method

      ## ------------ DOCS --------------
      ##~ sapi = source2swagger.namespace("Service Management API")
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions/authorize.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "GET"
      ##~ op.summary = "Authorize (App Id authentication pattern)"
      ##
      ##~ @authorize_desc = "<p>It is used to check if a particular application exists,"
      ##~ @authorize_desc = @authorize_desc + " is active and is within its usage limits. It can be optionally used to authenticate a call using an application key."
      ##~ @authorize_desc = @authorize_desc + " It's possible to pass a 'predicted usage' to the authorize call. This can serve two purposes:<p>1) To make sure an API"
      ##~ @authorize_desc = @authorize_desc + " call won't go over the limits before the call is made, if the usage of the call is known in advance. In this case, the"
      ##~ @authorize_desc = @authorize_desc + " estimated usage can be passed to the authorize call, and it will respond whether the actual API call is still within limit."
      ##~ @authorize_desc = @authorize_desc + " And, <p>2) To limit the authorization only to a subset of metrics. If usage is passed in, only the metrics listed in it will"
      ##~ @authorize_desc = @authorize_desc + " be checked against the limits. For example: There are two metrics defined: <em>searches</em> and <em>updates</em>. <em>updates</em> are already over"
      ##~ @authorize_desc = @authorize_desc + " limit, but <em>searches</em> are not. In this case, the user should still be allowed to do a search call, but not an update one."
      ##~ @authorize_desc = @authorize_desc + "<p><b>Note:</b> Even if the predicted usage is passed in, authorize is still a <b>read-only</b> operation. You have to make the report call"
      ##~ @authorize_desc = @authorize_desc + " to report the usage."
      ##
      ##~ @authorize_desc_response = "<p>The response can have an http response code: <code class='http'>200</code> OK (if authorization is granted), <code class='http'>409</code> (if it's not granted, typically application over limits or keys missing, check 'reason' tag), "
      ##~ @authorize_desc_response = @authorize_desc_response + " or <code class='http'>403</code> (for authentication errors, check 'error' tag) and <code class='http'>404</code> (not found)."

      ##~ op.description = "<p>Read-only operation to authorize an application in the App Id authentication pattern." + " "+ @authorize_desc + " " + @authorize_desc_response
      ##~ op.group = "authorize"
      ##
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_app_id
      ##~ op.parameters.add @parameter_app_key
      ##~ op.parameters.add @parameter_referrer
      ##~ op.parameters.add @parameter_user_id
      ##~ op.parameters.add @parameter_usage_predicted
      ##
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions/authorize.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "GET", :tags => ["authorize","user_key"], :nickname => "authorize_user_key", :deprecated => false
      ##~ op.summary = "Authorize (API Key authentication pattern)"
      ##
      ##~ op.description = "Read-only operation to authorize an application in the App Key authentication pattern." + " "+ @authorize_desc + " " + @authorize_desc_response
      ##~ op.group = "authorize"
      ##
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_user_key
      ##~ op.parameters.add @parameter_referrer
      ##~ op.parameters.add @parameter_user_id
      ##~ op.parameters.add @parameter_usage_predicted
      ##
      get '/transactions/authorize.xml' do
        do_api_method :authorize
      end

      ## ------------ DOCS --------------
      ##~ sapi = source2swagger.namespace("Service Management API")
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions/oauth_authorize.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "GET", :tags => ["authorize","user_key"], :nickname => "oauth_authorize", :deprecated => false
      ##~ op.summary = "Authorize (OAuth authentication mode pattern)"
      ##
      ##~ op.description = "<p>Read-only operation to authorize an application in the OAuth authentication pattern."
      ##~ @oauth_desc_response = "<p>This calls returns extra data (secret and redirect_url) needed to power OAuth APIs. It's only available for users with OAuth enabled APIs."
      ##~ op.description = op.description + @oauth_desc_response
      ##~ op.description = op.description + " " + @authorize_desc + " " + @authorize_desc_response
      ##~ op.group = "authorize"
      ##
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_access_token
      ##~ op.parameters.add @parameter_client_id
      ##~ op.parameters.add @parameter_referrer
      ##~ op.parameters.add @parameter_user_id_oauth
      ##~ op.parameters.add @parameter_usage_predicted
      ##~ op.parameters.add @parameter_redirect_url
      ##~ op.parameters.add @parameter_redirect_uri
      ##
      get '/transactions/oauth_authorize.xml' do
        do_api_method :oauth_authorize
      end

      ## ------------ DOCS --------------
      ##~ sapi = source2swagger.namespace("Service Management API")
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions/authrep.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "GET"
      ##~ op.summary = "AuthRep (Authorize + Report for the App Id authentication pattern)"
      ##
      ##~ @authrep_desc_base = "<p>Authrep is a <b>'one-shot'</b> operation to authorize an application and report the associated transaction at the same time."
      ##~ @authrep_desc = "<p>The main difference between this call and the regular authorize call is that"
      ##~ @authrep_desc = @authrep_desc + " usage will be reported if the authorization is successful. Authrep is the most convenient way to integrate your API with the"
      ##~ @authrep_desc = @authrep_desc + " 3scale's Service Manangement API since it does a 1:1 mapping between a request to your API and a request to 3scale's API."
      ##~ @authrep_desc = @authrep_desc + "<p>If you do not want to do a request to 3scale for each request to your API or batch the reports you should use the Authorize and Report methods instead."
      ##~ @authrep_desc = @authrep_desc + "<p>Authrep is <b>not a read-only</b> operation and will increment the values if the authorization step is a success."
      ##
      ##~ op.description = @authrep_desc_base + @authrep_desc
      ##~ op.group = "authrep"
      ##
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_app_id
      ##~ op.parameters.add @parameter_app_key
      ##~ op.parameters.add @parameter_referrer
      ##~ op.parameters.add @parameter_user_id
      ##~ op.parameters.add @parameter_usage
      ##~ op.parameters.add @parameter_log
      ##
      ##
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions/authrep.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "GET"
      ##~ op.summary = "AuthRep (Authorize + Report for the API Key authentication pattern)"
      ##~ op.description = @authrep_desc_base + @authrep_desc
      ##~ op.group = "authrep"
      ##
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_user_key
      ##~ op.parameters.add @parameter_referrer
      ##~ op.parameters.add @parameter_user_id
      ##~ op.parameters.add @parameter_usage
      ##~ op.parameters.add @parameter_log
      ##
      get '/transactions/authrep.xml' do
        do_api_method :authrep
      end

      ## ------------ DOCS --------------
      ##~ sapi = source2swagger.namespace("Service Management API")
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions/oauth_authrep.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "GET", :nickname => "oauth_authrep", :deprecated => false
      ##~ op.summary = "AuthRep (OAuth authentication mode pattern)"
      ##
      ##~ op.description = "<p>Authrep is a <b>'one-shot'</b> operation to authorize an application and report the associated transaction at the same time in the OAuth authentication pattern."
      ##~ op.description = op.description + @authrep_desc + @oauth_desc_response
      ##~ op.group = "authrep"
      ##
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_access_token
      ##~ op.parameters.add @parameter_client_id
      ##~ op.parameters.add @parameter_referrer
      ##~ op.parameters.add @parameter_user_id_oauth
      ##~ op.parameters.add @parameter_usage
      ##~ op.parameters.add @parameter_log
      ##~ op.parameters.add @parameter_redirect_url
      ##~ op.parameters.add @parameter_redirect_uri
      ##
      get '/transactions/oauth_authrep.xml' do
        do_api_method :oauth_authrep
      end

      ## ------------ DOCS --------------
      ##~ sapi = source2swagger.namespace("Service Management API")
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "POST"
      ##~ op.summary = "Report (App Id authentication pattern)"

      ##~ @report_desc = "<p>Report the transactions to 3scale backend.<p>This operation updates the metrics passed in the usage parameter. You can send up to 1K"
      ##~ @report_desc = @report_desc + " transactions in a single POST request. Transactions are processed asynchronously by the 3scale's backend."
      ##~ @report_desc = @report_desc + "<p>Transactions from a single batch are reported only if all of them are valid. If there is an error in"
      ##~ @report_desc = @report_desc + " processing of at least one of them, none is reported.<p>Note that a batch can only report transactions to the same"
      ##~ @report_desc = @report_desc + " service, <em>service_id</em> is at the same level that <em>provider_key</em>. Multiple report calls will have to be issued to report"
      ##~ @report_desc = @report_desc + " transactions to different services."
      ##~ @report_desc = @report_desc + "<p>Be aware that reporting metrics that are limited at the time of reporting will have no effect."
      ##
      ##~ op.description = @report_desc
      ##~ op.group = "report"
      #
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_transaction_app_id
      ##
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "POST"
      ##~ op.summary = "Report (API Key authentication pattern)"
      ##~ op.description = @report_desc
      ##~ op.group = "report"
      #
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_transaction_api_key
      ##
      ##~ a = sapi.apis.add
      ##~ a.set "path" => "/transactions.xml", "format" => "xml"
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "POST"
      ##~ op.summary = "Report (OAuth authentication pattern)"
      ##~ op.description = @report_desc
      ##~ op.group = "report"
      #
      ##~ op.parameters.add @parameter_provider_key
      ##~ op.parameters.add @parameter_service_id
      ##~ op.parameters.add @parameter_transaction_oauth
      ##
      ##
      post '/transactions.xml' do
        provider_key = params[:provider_key]
        ## return error code 400 (Bad request) if the parameters are not there
        ## I put 403 (Forbidden) for consitency however it should be 400
        ## reg = /^([^:\/#?& @%+;=$,<>~\^`\[\]{}\| "]|%[A-F0-9]{2})*$/

        if params.nil? || blank?(provider_key)
          empty_response 403
          return
        end

        transactions = params[:transactions]
        if blank?(transactions) || !transactions.is_a?(Hash)
          empty_response 400
          return
        end

        if transactions.any? { |_id, data| data.nil? }
          empty_response 400
          return
        end

        ## not very proud of this but... this is to cover for those cases that it does not blow on
        ## rack_exception_catcher
        if !transactions.valid_encoding?
          status 400
          body ThreeScale::Backend::NotValidData.new().to_xml
          return
        end

        Transactor.report(provider_key, params[:service_id], transactions, response_code: 202, request: request_info)
        empty_response 202
      end

      ## OAUTH ACCESS TOKENS

      post '/services/:service_id/oauth_access_tokens.xml' do
        require_params! :provider_key, :service_id, :token

        # TODO: this should directly respond rather than raise
        unless Service.authenticate_service_id(params[:service_id], params[:provider_key])
          raise ProviderKeyInvalid, params[:provider_key]
        end

        unless Application.exists?(params[:service_id], params[:app_id])
          empty_response 404
          return
        end

        # Users do not need to exist, since they can be "created" on-demand.
        if OAuth::Token::Storage.create(params[:token], service_id, params[:app_id], params[:user_id], params[:ttl])
          empty_response 200
        else
          empty_response 422
        end
      end

      delete '/services/:service_id/oauth_access_tokens/:token.xml' do
        require_params! :provider_key, :service_id, :token

        # TODO: this should directly respond rather than raise
        unless Service.authenticate_service_id(params[:service_id], params[:provider_key])
          raise ProviderKeyInvalid, params[:provider_key]
        end

        # TODO: perhaps improve this to list the deleted tokens?
        code = if OAuth::Token::Storage.delete(params[:token], service_id)
                 200
               else
                 404
               end
        empty_response code
      end

      get '/services/:service_id/applications/:app_id/oauth_access_tokens.xml' do
        require_params! :provider_key, :service_id, :app_id

        # TODO: this should directly respond rather than raise
        unless Service.authenticate_service_id(params[:service_id], params[:provider_key])
          raise ProviderKeyInvalid, params[:provider_key]
        end

        service_id = params[:service_id]
        app_id = params[:app_id]

        unless Application.exists?(service_id, app_id)
          empty_response 404
          return
        end

        @tokens = OAuth::Token::Storage.all_by_service_and_app service_id, app_id, params[:user_id]
        builder :oauth_access_tokens
      end

      get '/services/:service_id/oauth_access_tokens/:token.xml' do
        require_params! :provider_key, :service_id, :token

        unless Service.authenticate_service_id(params[:service_id], params[:provider_key])
          raise ProviderKeyInvalid, params[:provider_key]
        end

        @token_to_app_id, @token_to_user_id = OAuth::Token::Storage.get_credentials(
          params[:token], params[:service_id]
        )

        builder :oauth_app_id_by_token
      end

      ## TRANSACTIONS & ERRORS

      get '/transactions/errors.xml' do
        @errors = ErrorStorage.list(service_id, :page     => params[:page],
                                                :per_page => params[:per_page])
        builder :transaction_errors
      end

      delete '/transactions/errors.xml' do
        ErrorStorage.delete_all(service_id)
        empty_response
      end

      get '/transactions/errors/count.xml' do
        @count = ErrorStorage.count(service_id)
        builder :transaction_error_count
      end

      get '/transactions/latest.xml' do
        @transactions = TransactionStorage.list(service_id)
        builder :latest_transactions
      end

      ## LOG REQUESTS

      get '/services/:service_id/applications/:app_id/log_requests.xml' do
        @list = LogRequestStorage.list_by_application(service_id, application.id)
        builder :log_requests
      end

      get '/applications/:app_id/log_requests.xml' do
        ## FIXME: two ways of doing the same
        ## get '/services/:service_id/applications/:app_id/log_requests.xml'
        @list = LogRequestStorage.list_by_application(service_id, application.id)
        builder :log_requests
      end

      get '/services/:service_id/log_requests.xml' do
        @list = LogRequestStorage.list_by_service(service_id)
        builder :log_requests
      end

      # TODO: This one's not used by System, safe for removal
      get '/services/:service_id/applications/:app_id/log_requests/count.xml' do
        @count = LogRequestStorage.count_by_application(service_id, application.id)
        builder :log_requests_count
      end

      # TODO: This one's not used by System, safe for removal
      get '/services/:service_id/log_requests/count.xml' do
        @count = LogRequestStorage.count_by_service(service_id)
        builder :log_requests_count
      end

      delete '/services/:service_id/applications/:app_id/log_requests.xml' do
        LogRequestStorage.delete_by_application(service_id, application.id)
        empty_response
      end

      delete '/applications/:app_id/log_requests.xml' do
        ## FIXME: two ways of doing the same
        ## delete '/services/:service_id/applications/:app_id/log_requests.xml'
        LogRequestStorage.delete_by_application(service_id, application.id)
        empty_response
      end

      delete '/services/:service_id/log_requests.xml' do
        LogRequestStorage.delete_by_service(service_id)
        empty_response
      end

      ## ALERTS & VIOLATIONS

      get "/services/:service_id/applications/:app_id/utilization.xml" do
        @usage_reports, @max_record, @max_utilization, @stats = Transactor.utilization(service_id, application.id)
        builder :utilization
      end

      get '/applications/:app_id/utilization.xml' do
        ## FIXME: two ways of doing the same
        ## "/services/:service_id/applications/:app_id/utilization.xml"
        @usage_reports, @max_record, @max_utilization, @stats = Transactor.utilization(service_id, application.id)
        builder :utilization
      end

      get '/check.txt' do
        content_type 'text/plain'
        body 'ok'
      end

      # using a class variable instead of settings because we want this to be
      # as fast as possible when responding, since we hit /status a lot.
      @@status = { status: :ok,
                   version: { backend: ThreeScale::Backend::VERSION } }.to_json

      get '/status' do
        content_type 'application/json'.freeze
        @@status
      end

      not_found do
        env['sinatra.error'] = nil
        [404, { 'Content-Type' => 'application/vnd.3scale-v2.0+xml' }, ['']]
      end

      private

      def blank?(object)
        !object || object.respond_to?(:empty?) && object.empty?
      end

      def valid_key_and_usage_params?
        params && !blank?(params[:provider_key]) && (params[:usage].nil? || params[:usage].is_a?(Hash))
      end

      def require_params!(*keys)
        raise RequiredParamsMissing unless params && keys.all? { |key| !blank?(params[key]) }
      end

      def normalize_non_empty_keys!
        return if params.nil?
        ## this is to minimize potential security hazzards with an empty user_key
        COMMON_PARAMS.each do |p|
          thisparam = params[p]
          params[p] = nil if !thisparam.nil? && (thisparam.class != String || thisparam.strip.empty?)
        end
      end

      def application
        @application ||= Application.load_by_id_or_user_key!(service_id, params[:app_id], params[:user_key])
      end

      # FIXME: this operations can be done more efficiently, without loading the whole service
      def service_id
        if params[:service_id].nil? || params[:service_id].empty?
          @service_id ||= Service.default_id!(params[:provider_key])
        else
          service = Service.load_by_id(params[:service_id])
          raise ProviderKeyInvalid, params[:provider_key] if service.nil? || service.provider_key!=params[:provider_key]
          @service_id ||= params[:service_id]
        end
      end

      def application_resource_url(application, type, value)
        url("/applications/#{application.id}/#{type}/#{value}.xml")
      end

      def url(path)
        protocol = request.env['HTTPS'] == 'on' ? 'https' : 'http'
        server   = request.env['SERVER_NAME']

        url = "#{protocol}://#{server}#{path}"
        url += "?provider_key=#{params[:provider_key]}" if params[:provider_key]
        url
      end

      def empty_response(code = 200)
        status code
        body nil
        true
      end

      ## FIXME: this has to be refactored when the api supports json all the way
      def error_response(e)
        content_type 'application/json'
        status 403
        body Yajl::Encoder.encode({:error => {:code => e.code, :message => e.message}})
        true
      end

      def request_info
        {
          url: request.url,
          method: request.request_method,
          form_vars: request.env["rack.request.form_vars"],
          user_agent: request.user_agent,
          ip: request.ip,
          content_type: request.content_type,
          content_length: request.content_length,
        }
      end
    end
  end
end
