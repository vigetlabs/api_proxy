# API Proxy

This is a basic proof of concept to test a read-through cache that proxies API
requests to an external service.

## Configuration

The file `configuration.rb` contains the settings for both caching (through
[VCR](https://github.com/vcr/vcr)) and the proxy configuration -- you can change
 the target endpoint here and configure any additional
[HTTP options](https://ruby-doc.org/stdlib-2.6.3/libdoc/net/http/rdoc/Net/HTTP.html#attribute-method-details)
recognized by the `Net::HTTP` standard library.

## Running

The entry point is implemented as a basic [Sinatra](http://sinatrarb.com/) app.
To run:

```
$ bundle
$ ruby app.rb
```

## How it Works

The application intercepts all HTTP requests and calculates a signature based
on the params and the request body and attempts to match that to an existing
cached response (using VCR's built-in recording capabilities).  On a cache hit,
the stored response is returned, otherwise the request is forwarded to the live
endpoint, cached, and the response is returned.

## Drawbacks

Requests that have the same signature but expect a different response on
subsequent requests currently do not work.  For example, a scenario where an
item is added to a user's cart:

1. `GET /carts/1` -- Initial request for a user's cart, the response will be
cached based on the path.
1. `POST /cart/items` -- Request to add an item to the user's cart (with
corresponding payload) that will result in a modification to the cart.
1. `GET /carts/1` -- A second request to get the updated cart information.
Rather than making a new request and fetching the updated data, this will return
the cached response from request #1.

This proxy will not currently work in these situations.
