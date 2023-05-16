component {

	function configure(){
		// Set Full Rewrites
		setFullRewrites( true );
		// Set Full Web HTTP Root
		setBaseUrl( "http://#cgi.http_host#/" );
		// Turn off domain discovery so we only server from one domain.
		// If you enable this, then you will need to override the base url on each request
		// Via a requestCapture() interceptor
		setMultiDomainDiscovery( false );

		/**
		 * --------------------------------------------------------------------------
		 * App Routes
		 * --------------------------------------------------------------------------
		 *
		 * Here is where you can register the routes for your web application!
		 * Go get Funky!
		 *
		 */

		// A nice healthcheck route example
		route( "/healthcheck", function( event, rc, prc ){
			return "Ok!";
		} );

		// A nice RESTFul Route example
		route( "/api/echo", function( event, rc, prc ){
			return { "error" : false, "data" : "Welcome to my awesome API!" };
		} );

		// @app_routes@

		// Conventions-Based Routing
		route( ":handler/:action?" ).end();
	}

}
