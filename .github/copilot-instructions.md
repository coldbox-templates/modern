# ColdBox Modern Template - AI Coding Instructions

This is a ColdBox HMVC framework template with a **security-first architecture** that separates application code (`/app`) from the public webroot (`/public`). Compatible with Adobe ColdFusion 2021+ and BoxLang 1.0+. **Lucee is NOT supported.**

## 🏗️ Architecture Overview

**Critical Design Decision**: Unlike traditional templates where everything lives in the webroot, this template uses `/public` as the document root with application code in `/app` (outside webroot). This requires CommandBox aliases or web server configuration.

### Directory Structure

```
/app/                  - Application code (NOT web-accessible)
├── Application.cfc   - Security barrier (contains only "abort;")
├── config/           - Framework configuration
│   ├── ColdBox.cfc  - Main framework settings
│   └── Router.cfc   - URL routing definitions
├── handlers/         - Event handlers (controllers)
├── models/           - Service objects, business logic
├── views/            - HTML templates
├── layouts/          - Page layouts
├── helpers/          - Application helper functions
└── interceptors/     - Event interceptors

/public/               - Document root (web-accessible)
├── Application.cfc   - Bootstrap that maps to /app
├── index.cfm         - Front controller
└── includes/         - Static assets (CSS, JS, images)

/lib/                  - Framework dependencies
├── coldbox/          - ColdBox framework
├── testbox/          - TestBox testing framework
└── modules/          - CommandBox-installed modules (cbdebugger, cbswagger, etc.)

/tests/                - Test suites
└── specs/            - BDD test specifications
```

### Application Bootstrap Flow

1. Request hits `/public/index.cfm`
2. `/public/Application.cfc` sets **critical mappings**:
   - `COLDBOX_APP_ROOT_PATH = this.mappings["/app"]`
   - `COLDBOX_APP_MAPPING = "/app"`
   - `COLDBOX_WEB_MAPPING = "/"` (or "/yourApp" for subfolders)
3. ColdBox loads `/app/config/ColdBox.cfc`
4. Routes defined in `/app/config/Router.cfc`
5. Handlers in `/app/handlers/` process requests

**Security**: `/app/Application.cfc` contains only `abort;` to prevent direct web access.

## 🚨 CommandBox Aliases (CRITICAL)

This template **REQUIRES** CommandBox aliases in `server.json` to expose internal assets:

```json
"web": {
    "webroot": "public",
    "aliases": {
        "/coldbox/system/exceptions": "./lib/coldbox/system/exceptions/",
        "/tests": "./tests/"
    }
}
```

**⚠️ CRITICAL**: When installing modules with UI assets (cbdebugger, cbswagger, etc.), you **MUST** add corresponding aliases or they won't load:

```json
"aliases": {
    "/cbdebugger": "./lib/modules/cbdebugger/",
    "/cbswagger": "./lib/modules/cbswagger/"
}
```

**Common Issue**: Module returns 404 errors → Missing alias in `server.json`

## 📝 Handler Patterns

All handlers extend `coldbox.system.EventHandler` and receive three arguments:

```cfml
component extends="coldbox.system.EventHandler" {

    // Dependency injection
    property name="userService" inject="UserService";

    /**
     * @event RequestContext - get/set values, rendering, redirects
     * @rc    Request Collection - URL/FORM variables (untrusted)
     * @prc   Private Request Collection - handler-to-view data (trusted)
     */
    function index(event, rc, prc){
        prc.welcomeMessage = "Data for view";
        event.setView("main/index");
    }

    // RESTful data - return any type
    function data(event, rc, prc){
        return [{id: createUUID(), name: "Luis"}];
    }

    // Relocations (redirects)
    function doSomething(event, rc, prc){
        relocate("main.index");
    }

    // Lifecycle handlers (optional)
    function onAppInit(event, rc, prc){}
    function onRequestStart(event, rc, prc){}
    function onException(event, rc, prc){
        event.setHTTPHeader(statusCode=500);
        var exception = prc.exception;
    }
}
```

**Critical Pattern**: `rc` = untrusted input, `prc` = trusted internal data

## 🧪 Testing Patterns

**CRITICAL**: Tests extend `BaseTestCase` with `appMapping="/app"`:

```cfml
component extends="coldbox.system.testing.BaseTestCase" appMapping="/app" {

    function run(){
        describe("Main Handler", function(){
            beforeEach(function(currentSpec){
                // MUST call setup() to reset request context
                setup();
            });

            it("can render the homepage", function(){
                var event = this.get("main.index");
                expect(event.getValue(name="welcomeMessage", private=true))
                    .toBe("Welcome to ColdBox!");
            });

            it("can return RESTful data", function(){
                var event = this.post("main.data");
                expect(event.getRenderedContent()).toBeJSON();
            });
        });
    }
}
```

**Common Mistakes**:
- ❌ Forgetting `setup()` in `beforeEach()` → Tests share request context
- ❌ Wrong `appMapping` → Tests fail to find application
- ✅ Always call `setup()` for test isolation

## 🛠️ Build Commands

```bash
# Install dependencies
box install

# Start server
box server start

# Code formatting
box run-script format              # Format all CFML
box run-script format:check        # Check formatting
box run-script format:watch        # Watch and auto-format

# Testing
box testbox run                    # Run all tests
box testbox run bundles=tests.specs.integration.MainSpec

# Scaffolding
coldbox create handler name=Users actions=index,save
coldbox create model name=UserService methods=getAll,save
coldbox create integration-test handler=Users

# Docker
box run-script build:docker        # Build image
box run-script run:docker          # Run container
```

## 🎯 Configuration Patterns

### Environment Variables (.env)

The `postInstall` script auto-creates `.env` from `.env.example`. Access with `getSystemSetting()`:

```cfml
// app/config/ColdBox.cfc
variables.coldbox = {
    appName: getSystemSetting("APPNAME", "Default")
};

// In handlers/models
var dbHost = getSystemSetting("DB_HOST", "localhost");
```

### Application Helper

`/app/helpers/ApplicationHelper.cfm` is available in all handlers, views, layouts:

```cfml
<!--- app/helpers/ApplicationHelper.cfm --->
<cfscript>
function formatCurrency(required numeric amount){
    return dollarFormat(arguments.amount);
}
</cfscript>
```

### Implicit Event Handlers

Configure in `/app/config/ColdBox.cfc`:

```cfml
variables.coldbox = {
    applicationStartHandler: "Main.onAppInit",
    requestStartHandler: "Main.onRequestStart",
    exceptionHandler: "main.onException"
};
```

## 🔄 Routing (app/config/Router.cfc)

```cfml
component {
    function configure(){
        // Closure routes
        route("/healthcheck", function(event, rc, prc){
            return "Ok!";
        });

        // RESTful resources
        resources("photos");

        // Pattern routes
        route("/users/:id").to("users.show");

        // Route groups
        group({prefix: "/api/v1"}, function(){
            route("/users").to("api.users.index");
        });

        // Conventions-based (MUST be last)
        route(":handler/:action?").end();
    }
}
```

## 💉 Dependency Injection (WireBox)

```cfml
component {
    // Inject by model name
    property name="userService" inject="UserService";

    // Inject by ID
    property name="cache" inject="cachebox:default";

    // Inject logger
    property name="log" inject="logbox:logger:{this}";

    // Provider injection (lazy)
    property name="provider" inject="provider:UserService";
}
```

**Auto-Discovery**: Models in `/app/models/` are automatically registered when `autoMapModels=true`.

## 🚨 Common Pitfalls

1. **Missing Aliases**: Module UI assets return 404 → Add alias to `server.json`
2. **Test Isolation**: Forgetting `setup()` → Tests mysteriously fail
3. **appMapping**: Tests need `appMapping="/app"` to match public/Application.cfc
4. **Webroot Confusion**: Don't put code in `/public` except static assets
5. **Direct /app Access**: `/app/Application.cfc` abort prevents web access (security feature)
6. **Library Paths**: box.json installs to `lib/coldbox/`, `lib/testbox/` (note the subdirs)

## 📚 Key Files

- `public/Application.cfc` - Bootstrap with mappings (COLDBOX_APP_ROOT_PATH, COLDBOX_APP_MAPPING)
- `app/Application.cfc` - Security barrier (only contains `abort;`)
- `app/config/ColdBox.cfc` - Framework configuration
- `app/config/Router.cfc` - URL routing
- `server.json` - **CRITICAL** aliases for modules
- `box.json` - Dependencies, scripts
- `tests/Application.cfc` - Test bootstrap (mirrors public/Application.cfc)

## 🔍 Debugging

```cfml
// Enable debug in app/config/ColdBox.cfc
variables.settings = { debugMode: true };

// Dump in handlers
writeDump(var=rc, abort=true);

// Inject logger
property name="log" inject="logbox:logger:{this}";
log.info("Debug", rc);

// TestBox debug
debug(event.getHandlerResults());
```

## 📖 Documentation

- ColdBox: https://coldbox.ortusbooks.com
- WireBox: https://wirebox.ortusbooks.com
- TestBox: https://testbox.ortusbooks.com
- CommandBox: https://commandbox.ortusbooks.com
