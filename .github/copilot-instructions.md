# ColdBox Modern Template - AI Coding Instructions

This is a ColdBox HMVC framework template with a "modern" folder structure that separates application code from the public webroot. Use CFML/BoxLang with ColdBox 7+ conventions.

## 🏗️ Architecture Overview

**Key Design Decision**: Unlike traditional templates where everything lives in the webroot, this template uses `/public` as the document root with application code in `/app`. This requires CommandBox aliases or web server configuration to expose internal paths.

### Critical Paths

```
/app/              - Application code (handlers, models, views, config)
/public/           - Public webroot (index.cfm, static assets)
  /Application.cfc - Entry point that maps to /app via COLDBOX_APP_ROOT_PATH
/lib/              - Framework and dependency storage
  /coldbox/        - ColdBox framework files
  /testbox/        - TestBox testing framework
  /java/           - Java JAR dependencies
  /modules/        - CommandBox-installed modules
/tests/            - Test suites
/resources/        - Non-web resources (migrations, apidocs, assets)
```

### Application Bootstrap Flow

1. Request hits `/public/index.cfm`
2. `/public/Application.cfc` sets critical mappings:
   - `COLDBOX_APP_ROOT_PATH = this.mappings["/app"]`
   - `COLDBOX_APP_MAPPING = "/app"`
   - `COLDBOX_WEB_MAPPING = "/"` (or "/yourApp" for subfolders)
3. ColdBox loads config from `/app/config/ColdBox.cfc`
4. Routes defined in `/app/config/Router.cfc`
5. Handlers in `/app/handlers/` process requests

**Security Note**: `/app/Application.cfc` contains only `abort;` to prevent direct web access to application code.

## 🔧 CommandBox Aliases (Critical for Operation)

This template **requires** CommandBox aliases in `server.json` to expose internal assets:

```json
"web": {
    "webroot": "public",
    "aliases": {
        "/coldbox/system/exceptions": "./lib/coldbox/system/exceptions/",
        "/tests": "./tests/"
    }
}
```

**When adding modules with UI assets** (cbdebugger, cbswagger, etc.), you MUST add corresponding aliases or they won't load.

## 📝 Handler Patterns

### Standard Handler Structure

```cfml
component extends="coldbox.system.EventHandler" {

    // All actions receive three arguments:
    // - event: RequestContext object
    // - rc: Request collection (form/URL variables)
    // - prc: Private request collection (handler-to-view data)

    function index(event, rc, prc){
        prc.welcomeMessage = "Data for the view";
        event.setView("main/index");
    }

    // RESTful data - return any data type, ColdBox handles marshalling
    function data(event, rc, prc){
        return [
            { "id": createUUID(), "name": "Luis" }
        ];
    }

    // Relocations
    function doSomething(event, rc, prc){
        relocate("main.index"); // Internal redirect to event
    }

    // Lifecycle handlers (optional)
    function onAppInit(event, rc, prc){}
    function onRequestStart(event, rc, prc){}
    function onRequestEnd(event, rc, prc){}

    // Exception handling
    function onException(event, rc, prc){
        event.setHTTPHeader(statusCode = 500);
        var exception = prc.exception; // Populated by ColdBox
    }
}
```

### Request Collection Conventions

- **rc (Request Collection)**: Automatically populated with FORM/URL variables. Never trust this data - always validate.
- **prc (Private Request Collection)**: Pass data from handlers to views/layouts. Not accessible from URL.

Example:
```cfml
function show(event, rc, prc){
    // rc.id comes from URL/FORM
    prc.user = userService.get(rc.id ?: 0);
    event.setView("users/show");
}
```

## 🗺️ Routing Patterns

In `/app/config/Router.cfc`:

```cfml
component {
    function configure(){
        // Named routes
        route("/healthcheck", function(event, rc, prc){
            return "Ok!";
        });

        // RESTful resources
        route("/api/echo", function(event, rc, prc){
            return { "error": false, "data": "Welcome!" };
        });

        // Conventions-based routing (keep at end)
        route(":handler/:action?").end();
    }
}
```

URL format: `/?event=handler.action` or `/handler/action` (with URL rewriting)

## 🧪 Testing Patterns

Tests extend `coldbox.system.testing.BaseTestCase` with `appMapping="/app"`:

```cfml
component extends="coldbox.system.testing.BaseTestCase" appMapping="/app" {

    function beforeAll(){
        super.beforeAll();
        // Global test setup
    }

    function run(){
        describe("Main Handler", function(){
            beforeEach(function(currentSpec){
                // CRITICAL: Call setup() to create fresh request context
                setup();
            });

            it("can render the homepage", function(){
                var event = this.get("main.index");
                expect(event.getValue(name="welcomeMessage", private=true))
                    .toBe("Welcome to ColdBox!");
            });

            it("can handle POST requests", function(){
                var event = this.post("main.data");
                expect(event.getRenderedContent()).toBeJSON();
            });

            it("can test relocations", function(){
                var event = execute(event="main.doSomething");
                expect(event.getValue("relocate_event", "")).toBe("main.index");
            });
        });
    }
}
```

**Key Testing Methods**:
- `this.get(event)` / `this.post(event)` - Simulate HTTP requests
- `execute(event)` - Execute event without HTTP simulation
- `event.getValue(name, default, private)` - Get from rc/prc
- `event.getHandlerResults()` - Get return value from handler
- `event.getRenderedContent()` - Get rendered view output

## 💉 Dependency Injection

Use WireBox annotations in components:

```cfml
component {
    property name="userService" inject="UserService";
    property name="wirebox" inject="wirebox";
    property name="cachebox" inject="cachebox";
    property name="logbox" inject="logbox";

    function list(){
        return userService.getAll();
    }
}
```

**Injection Shortcuts**:
- `inject="coldbox"` - ColdBox controller
- `inject="wirebox"` - WireBox injector
- `inject="cachebox"` - CacheBox
- `inject="logbox"` - LogBox
- `inject="coldbox:setting:settingName"` - Application setting

## 🔨 Build & Development Commands

```bash
# Install dependencies
box install

# Start server (uses server.json config)
box server start

# Run tests
box testbox run

# Code formatting
box run-script format          # Format all code
box run-script format:check    # Check formatting
box run-script format:watch    # Watch mode

# Docker
box run-script build:docker    # Build Docker image
box run-script run:docker      # Run container
```

## 📦 Java Dependencies (Optional)

Add Maven dependencies to `pom.xml`:

```xml
<dependencies>
    <dependency>
        <groupId>com.google.code.gson</groupId>
        <artifactId>gson</artifactId>
        <version>2.10.1</version>
    </dependency>
</dependencies>
```

Then run: `mvn install` - JARs copied to `/lib/java/` and auto-loaded by `Application.cfc`.

## 🔐 Configuration Patterns

### Environment Variables

Copy `.env.example` to `.env` and use `getSystemSetting()`:

```cfml
// In /app/config/ColdBox.cfc
variables.coldbox = {
    appName: getSystemSetting("APPNAME", "Default App Name")
};
```

### Module Installation

When installing modules with web assets:

1. `box install cbdebugger`
2. Add alias to `server.json`:
   ```json
   "aliases": {
       "/cbdebugger": "./modules/cbdebugger"
   }
   ```
3. Restart server

## 🚨 Common Pitfalls

1. **Missing Aliases**: Modules with UI assets won't work without CommandBox aliases
2. **Test Isolation**: Always call `setup()` in `beforeEach()` for fresh request context
3. **Private vs Public Data**: Use `prc` for handler-to-view data, never expose via URL
4. **Application Mapping**: Test `appMapping="/app"` must match production paths
5. **Webroot Confusion**: Public files go in `/public`, not `/app`

## 🎯 When to Use This Template

- **Use Modern Template**: Secure environments, production apps, when you want application code outside webroot
- **Use Default Template**: Development, simple apps, when you need everything in webroot

This template requires understanding of web server aliases and CommandBox configuration.
