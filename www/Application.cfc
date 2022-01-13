/**
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

	// Application properties
	this.name              = hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout    = createTimespan( 0, 0, 30, 0 );
	this.setClientCookies  = true;

	// Java Integration
	this.javaSettings = {
		loadPaths               : [ expandPath( "../lib" ) ],
		loadColdFusionClassPath : true,
		reloadOnChange          : false
	};

	// webroot + Includes
	this.mappings[ "/www" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings[ "/includes" ] = this.mappings[ "/www" ] & "includes";
	// app root
	rootPath = REReplaceNoCase( this.mappings[ "/www" ], "www(\\|/)", "" );
	// app core
	this.mappings[ "/app" ] = rootPath & "app";
	// logs
	this.mappings[ "/logs" ] = rootPath & "logs";
	// coldbox
	this.mappings[ "/coldbox" ] = rootPath & "vendor/coldbox";
	// Modules
	this.mappings[ "/modules" ] = rootPath & "modules";

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = this.mappings[ "/app" ];
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "/app";
	COLDBOX_WEB_MAPPING   = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE   = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY       = "";
	// By default if an app is reiniting and a request hits it, we will fail fast with a message
	COLDBOX_FAIL_FAST = true

	// application start
	public boolean function onApplicationStart() {
		application.cbBootstrap = new coldbox.system.Bootstrap(
			COLDBOX_CONFIG_FILE,
			COLDBOX_APP_ROOT_PATH,
			COLDBOX_APP_KEY,
			COLDBOX_APP_MAPPING,
			COLDBOX_FAIL_FAST,
			COLDBOX_WEB_MAPPING
		);
		application.cbBootstrap.loadColdbox();
		return true;
	}

	// application end
	public void function onApplicationEnd( struct appScope ) {
		arguments.appScope.cbBootstrap.onApplicationEnd( arguments.appScope );
	}

	// request start
	public boolean function onRequestStart( string targetPage ) {

		if ( url.keyExists( "appreinit" ) ){
			structdelete( application, "cbBootstrap" );
			onApplicationStart();
		}

		// Process ColdBox Request
		application.cbBootstrap.onRequestStart( arguments.targetPage );

		return true;
	}

	public void function onSessionStart() {
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ) {
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection = arguments );
	}

	public boolean function onMissingTemplate( template ) {
		return application.cbBootstrap.onMissingTemplate( argumentCollection = arguments );
	}

}
