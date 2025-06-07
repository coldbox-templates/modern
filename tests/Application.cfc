/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
*/
component{

	// APPLICATION CFC PROPERTIES
	this.name 				= "ColdBoxTestingSuite";
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 0, 15, 0 );
	this.applicationTimeout = createTimeSpan( 0, 0, 15, 0 );
	this.setClientCookies 	= true;
	this.whiteSpaceManagement = "smart";
	this.enableNullSupport = shouldEnableFullNullSupport();

	// Create testing mapping
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// Map back to its root
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	// App Mappings
	this.mappings[ "/app" ]     = rootPath & "app";
	this.mappings[ "/lib" ]     = rootPath & "lib";
	this.mappings[ "/logs" ]    = rootPath & "logs";
	this.mappings[ "/modules" ] = rootPath & "lib/modules";
	this.mappings[ "/root" ]    = rootPath & "public";
	this.mappings[ "/coldbox" ] = this.mappings[ "/lib" ] & "/coldbox";
	this.mappings[ "/testbox" ] = this.mappings[ "/lib" ] & "/testbox";

	public boolean function onRequestStart( targetPage ){
		// Set a high timeout for long running tests
		setting requestTimeout="9999";
		// New ColdBox Virtual Application Starter
		request.coldBoxVirtualApp = new coldbox.system.testing.VirtualApp( appMapping = "/app" );

		// If hitting the runner or specs, prep our virtual app and database
		if ( getBaseTemplatePath().replace( expandPath( "/tests" ), "" ).reFindNoCase( "(runner|specs)" ) ) {
			request.coldBoxVirtualApp.startup( true );
		}

		// ORM Reload for fresh results
		if( structKeyExists( url, "fwreinit" ) ){
			if( structKeyExists( server, "lucee" ) ){
				pagePoolClear();
			}
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
