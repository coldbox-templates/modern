/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
*/
component{

	/**
	 * --------------------------------------------------------------------------
	 * Application Properties: Modify as you see fit!
	 * --------------------------------------------------------------------------
	 */
	this.name 				= "ColdBoxTestingSuite";
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 0, 15, 0 );
	this.applicationTimeout = createTimeSpan( 0, 0, 15, 0 );
	this.setClientCookies 	= true;
	this.whiteSpaceManagement = "smart";
	this.enableNullSupport = shouldEnableFullNullSupport();

	/**
	 * --------------------------------------------------------------------------
	 * Location Mappings
	 * --------------------------------------------------------------------------
	 * These are pre-defined in the runtime/config/boxlang.json so they can
	 * be reused.  You can change them here if you want.
	 */
	_testsRoot = getDirectoryFromPath( getCurrentTemplatePath() );
	_root = reReplaceNoCase( _testsRoot, "(/|\\)tests", "" );

	this.mappings[ "/tests" ] = _testsRoot;
	// App Mappings
	this.mappings[ "/app" ]     = _root & "app";
	this.mappings[ "/public" ]     = _root & "public";
	this.mappings[ "/modules" ] = _root & "lib/modules";
	this.mappings[ "/coldbox" ] = _root & "/lib/coldbox";
	this.mappings[ "/testbox" ] = _root & "/lib/testbox";

	public boolean function onRequestStart( targetPage ){
		// Set a high timeout for long running tests
		setting requestTimeout="9999";
		// New ColdBox Virtual Application Starter
		request.coldBoxVirtualApp = new coldbox.system.testing.VirtualApp(
			appMapping = "/app",
			webMapping = "/public"
		);

		// If hitting the runner or specs, prep our virtual app and database
		if ( getBaseTemplatePath().replace( expandPath( "/tests" ), "" ).reFindNoCase( "(runner|specs)" ) ) {
			request.coldBoxVirtualApp.startup( true );
		}

		// ORM Reload for fresh results
		if( structKeyExists( url, "fwreinit" ) ){
			// ormReload();
			request.coldBoxVirtualApp.restart();
		}

		return true;
	}

	public void function onRequestEnd( required targetPage ) {
		request.coldBoxVirtualApp.shutdown();
	}

	private boolean function shouldEnableFullNullSupport() {
        var system = createObject( "java", "java.lang.System" );
        var value = system.getEnv( "FULL_NULL" );
        return isNull( value ) ? false : !!value;
    }
}
