/**
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

	// Application properties
	this.name              = "ColdBox Application";
	this.sessionManagement = true;
	this.sessionTimeout    = createTimespan( 0, 0, 30, 0 );
	this.setClientCookies  = true;

	// Public Root Mapping
	this.mappings[ "/root" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// Public Includes
	this.mappings[ "/includes" ] = this.mappings[ "/root" ] & "includes";
	// Outside the Root Path, one back
	rootPath = REReplaceNoCase( this.mappings[ "/root" ], "public(\\|/)", "" );
	// ColdBox App core
	this.mappings[ "/app" ] = rootPath & "app";
	// Libs
	this.mappings[ "/lib" ] = rootPath & "lib";
	// Logs
	this.mappings[ "/logs" ] = rootPath & "logs";
	// ColdBox
	this.mappings[ "/coldbox" ] = this.mappings[ "/lib" ] & "/coldbox";
	// Modules
	this.mappings[ "/modules" ] = this.mappings[ "/lib" ] & "/modules";

	// Java Integration
	this.javaSettings = {
		loadPaths               : [ expandPath( "/lib/java" ) ],
		loadColdFusionClassPath : true,
		reloadOnChange          : false
	};

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = this.mappings[ "/app" ];
	// THE MAPPING LOCATION OF THE COLDBOX CORE APP
	COLDBOX_APP_MAPPING   = "/app";
	// THE WEB PATH LOCATION OF THE PUBLIC ASSETS, EMPTY FOR THE ROOT.
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
