Configuration of an app
-----------------------

The main part of an app is its configuration. Here you define the layout blocks, the middleware an the routes it
listens to. The directory-structure of a simple 'Hello world'-App might look like this:

::
    apps/
      hello-world/
        config.coffee
    node-modules/
      ...
    app.coffee

The config.coffee itself may look like the following:

::
    module.exports.config = 
        childs:
            'helloWorld':
                route: /.*/
                method: () -> 'Hello World'

* Line 1: This is the Common JS pattern for exposing internals of a module to the open, every mosaik module has to expose
at least this configuration.
* Line 2: 'childs' is always the node name for defining children block of the block containing the node. Since we are in
  the ROOT, child is the point where to define the different websites or routes or blocks which in this case is nearly
  the same.
* Line 3: This is the name of the block/route/website. Since it has to be unique over all the blocks on every site it
  should be more specific in large sites.
* Line 4: This is the route where, on which the server should serve this block. It can be a single string, a regualar
  expression,
    
