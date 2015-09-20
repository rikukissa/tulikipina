# Tulikipina.fi
![](http://i.imgur.com/oQlKEb2.png)

## Getting things up and running

    git clone git@github.com:rikukissa/tulikipina.git
    npm install
    npm start
    open http://localhost:9001 in your browser

## Commands
* npm install
    * Installs server-side dependencies from NPM and client-side dependencies from Bower
* npm start
    * Compiles your files, starts watching files for changes, serves static files to port 9001
* npm run build
    * Builds & minifies everything

:warning: Add prerender token to src/assets/.htaccess before deploying to production

