/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component{

	// APPLICATION CFC PROPERTIES
	this.name 				= "ColdBoxTestingSuite" & hash(getCurrentTemplatePath());
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 0, 15, 0 );
	this.applicationTimeout = createTimeSpan( 0, 0, 15, 0 );
	this.setClientCookies 	= true;

	// Create testing mapping
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// Map back to its root
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	// App Mappings
	this.mappings[ "/app" ] =  rootPath & "app";
	this.mappings[ "/coldbox" ] = rootPath & "coldbox";
	this.mappings[ "/lib" ] = rootPath & "lib";
	this.mappings[ "/logs" ] = rootPath & "logs";
	this.mappings[ "/modules" ] = rootPath & "modules";
	this.mappings[ "/testbox" ] = rootPath & "testbox";
	this.mappings[ "/root" ] = rootPath & "public";

	public void function onRequestEnd() {

		if( !isNull( application.cbController ) ){
			application.cbController.getLoaderService().processShutdown();
		}

		structDelete( application, "cbController" );
		structDelete( application, "wirebox" );
	}
}
