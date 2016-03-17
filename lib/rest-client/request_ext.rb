module RestClientExt
  module ProxyRequest
     def net_http_class
      if RestClient.proxy
        proxy_uri = URI.parse(RestClient.proxy)
        Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
      elsif @args[:proxy]
        proxy_uri = URI.parse(@args[:proxy])
        Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
      else
        Net::HTTP
      end
    end
  end
end