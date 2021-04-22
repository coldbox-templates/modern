# Modern Organization Template

This template is a work in progress where we are testing a different approach to ColdBox templates.
Instead of having all files in the web root, this template only puts browsable files in the web root. 
If you are using CommandBox, everything should "just work" but if you want to run this behind IIS/Apache, etc you'll need to re-create the web server aliases that are in the `server.json`.

## License

Apache License, Version 2.0.

## Important Links

Source Code

- https://github.com/coldbox-templates/modern

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