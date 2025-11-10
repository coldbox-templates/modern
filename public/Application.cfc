/**
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Application Bootstrap
 */
component {

	/**
	 * --------------------------------------------------------------------------
	 * Application Properties: Modify as you see fit!
	 * --------------------------------------------------------------------------
	 */
	this.name              = "ColdBox Application";
	this.sessionManagement = true;
	this.sessionTimeout    = createTimespan( 0, 0, 30, 0 );
	this.setClientCookies  = true;
	this.setDomainCookies     = true;
	this.timezone             = "UTC";
	this.whiteSpaceManagement = "smart";

	/**
	 * --------------------------------------------------------------------------
	 * Location Mappings
	 * --------------------------------------------------------------------------
	 * These are pre-defined in the runtime/config/boxlang.json so they can
	 * be reused.  You can change them here if you want.
	 */
	_publicRoot = getDirectoryFromPath( getCurrentTemplatePath() );
	_libRoot    = reReplaceNoCase( _publicRoot, "(/|\\)public", "lib/java" );
	_root = reReplaceNoCase( _publicRoot, "(/|\\)public", "" );

	this.mappings[ "/public" ]     = _publicRoot;
	this.mappings[ "/app" ]     = _root & "app";
	this.mappings[ "/coldbox" ]     = _root & "lib/coldbox";
	this.mappings[ "/modules" ]     = _root & "lib/modules";

	/**
	 * --------------------------------------------------------------------------
	 * App Class Loader
	 * --------------------------------------------------------------------------
	 */
	this.javaSettings = {
		loadPaths               : [ _libRoot ],
		loadColdFusionClassPath : true,
		reloadOnChange          : false
	};

	/**
	 * --------------------------------------------------------------------------
	 * ColdBox Bootstrap Settings
	 * --------------------------------------------------------------------------
	 * Modify only if you need to, else default them.
	 * https://coldbox.ortusbooks.com/getting-started/configuration/bootstrapper-application.cfc
	 */
	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = this.mappings[ "/app" ]
	// THE MAPPING LOCATION OF THE COLDBOX CORE APP
	COLDBOX_APP_MAPPING   = "/app"
	// THE WEB PATH LOCATION OF THE PUBLIC ASSETS, USUALLY "/" FOR MOST APPS
	// USE Empty String "" IF YOUR APP IS IN THE ROOT OF THE WEB
	// OR "/yourApp" IF YOUR APP IS IN A SUBFOLDER
	COLDBOX_WEB_MAPPING   = "/"
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE   = ""
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY       = ""
	// By default if an app is reiniting and a request hits it, we will fail fast with a message
	COLDBOX_FAIL_FAST = true

	/**
	 * --------------------------------------------------------------------------
	 * ORM + Datasource Settings
	 * --------------------------------------------------------------------------
	 */
	this.datasource = "coldbox"

	/**
	 * Fires when the application starts
	 */
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

	/**
	 * Fires when the application ends
	 *
	 * @appScope The app scope
	 */
	public void function onApplicationEnd( struct appScope ) {
		arguments.appScope.cbBootstrap.onApplicationEnd( arguments.appScope );
	}

	/**
	 * Process a ColdBox Request
	 *
	 * @targetPage The requested page
	 */
	public boolean function onRequestStart( string targetPage ) {
		return application.cbBootstrap.onRequestStart( arguments.targetPage );
	}

	/**
	 * Fires on every session start
	 */
	public void function onSessionStart() {
		if ( !isNull( application.cbBootstrap ) ) {
			application.cbBootStrap.onSessionStart()
		}
	}

	/**
	 * Fires on session end
	 *
	 * @sessionScope The session scope
	 * @appScope     The app scope
	 */
	public void function onSessionEnd( struct sessionScope, struct appScope ) {
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection = arguments );
	}

	/**
	 * On missing template handler
	 *
	 * @template
	 */
	public boolean function onMissingTemplate( template ) {
		return application.cbBootstrap.onMissingTemplate( argumentCollection = arguments );
	}

}
