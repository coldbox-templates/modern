# Modern Organization Template

This template is a work in progress where we are testing a different approach to ColdBox templates.
Instead of having all files in the web root, this template only puts `public` files in the web root and thus called `public`.

If you are using CommandBox, everything should "just work" but if you want to run this behind IIS/Apache, etc you'll need to re-create the web server aliases that are in the `server.json`.

## Structure

* `app` - Location of the ColdBox CFML app (Handlers, config, interceptors, views, custom modules, etc.)
* `lib` - Java and framework libs
* `lib/coldbox` - ColdBox libs
* `lib/testbox` - TestBox libs
* `logs` - App and Server logs
* `modules` - CommandBox installed ColdBox modules
* `public` - Public webroot (UI assets, etc)
* `resources` - Migrations, apidocs, UI source assets
* `tests` - Tests

## Aliases

Everything is locked down by default. Any modules you install that require UI assets will require a CommandBox web alias (https://commandbox.ortusbooks.com/embedded-server/configuring-your-server/aliases) that you can provide easily in the `server.json`.  Here are the ones we ship with:

```js
"aliases":{
	// We expose the cbdebugger module
	"/modules/cbdebugger":"./modules/cbdebugger",
	// We expose the ColdBox Exceptions UI
	"/coldbox/system/exceptions":"./lib/coldbox/system/exceptions/",
	// Expose TestBox for testing purposes
	"/testbox":"./lib/testbox/",
	// Expose Tests for testing purposes
	"/tests":"./tests/"
}
```

## License

Apache License, Version 2.0.

## Important Links

Source Code

- https://github.com/coldbox-templates/modern

## Java Dependencies

If your project relies on Java third-party dependencies, you can use the included Maven `pom.xml` file in the root.  You can add your dependencies there and then run the `mvn install` command to download them into the `lib/java` folder.  The BoxLang application will automatically class load all the jars in that folder for you!  You can also use the `mvn clean` command to remove all the jars.

You can find Java dependencies here: <https://central.sonatype.com/>.  Just grab the Maven coordinates and add them to your `pom.xml` file.

## Quick Installation

Each application templates contains a `box.json` so it can leverage [CommandBox](http://www.ortussolutions.com/products/commandbox) for its dependencies.
Just go into each template directory and type:

```bash
box install
```

This will setup all the needed dependencies for each application template.  You can then type:

```bash
box server start
```

And run the application.

---

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
