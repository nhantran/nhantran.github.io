---
title:  "Make a https request using Akka Http!"
---

Using Akka Http to send a GET request to any website seems to be simple with following steps:

* Add akka-http dependencies to build.sbt

{% highlight scala %}
libraryDependencies ++= Seq(
    "com.typesafe.akka" %% "akka-http-core" % "2.4.7",
    "com.typesafe.akka" %% "akka-http-experimental" % "2.4.7"
)
{% endhighlight %}

* And add the following code to send a simple GET request:
{% highlight scala %}
implicit val system = ActorSystem("blogs")
implicit val materializer = ActorMaterializer()

val url = "http://www.nytimes.com/"
Http().singleRequest(HttpRequest(uri = Uri(url))).map { response =>
    //Do anything with response here
}
{% endhighlight %}

Next, you may want to request a https site, such as **https://www.youtube.com**. But the code above should hang.. 
The reason was the root CA of this site has not been imported into trust store. Let's resolve it by following steps:

* Get root CA via command line:
{% highlight bash %}
keytool -printcert -sslserver www.youtube.com -rfc
{% endhighlight %}

The 'keytool' command requires Java installed in your system 

* Copy the last certificate including '-----BEGIN CERTIFICATE-----' and '-----END CERTIFICATE-----' and pass over application.conf

{% highlight yaml %}
akka {
  ssl-config {
    trustManager = {
      stores = [
        { type = "PEM", data = """
-----BEGIN CERTIFICATE-----
MIIDfTCCAuagAwIBAgIDErvmMA0GCSqGSIb3DQEBBQUAME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQK
EwdFcXVpZmF4MS0wKwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkw
HhcNMDIwNTIxMDQwMDAwWhcNMTgwODIxMDQwMDAwWjBCMQswCQYDVQQGEwJVUzEWMBQGA1UEChMN
R2VvVHJ1c3QgSW5jLjEbMBkGA1UEAxMSR2VvVHJ1c3QgR2xvYmFsIENBMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEA2swYYzD99BcjGlZ+W988bDjkcbd4kdS8odhM+KhDtgPpTSEHCIja
WC9mOSm9BXiLnTjoBbdqfnGk5sRgprDvgOSJKA+eJdbtg/OtppHHmMlCGDUUna2YRpIuT8rxh0PB
FpVXLVDviS2Aelet8u5fa9IAjbkU+BQVNdnARqN7csiRv8lVK83Qlz6cJmTM386DGXHKTubU1Xup
Gc1V3sjs0l44U+VcT4wt/lAjNvxm5suOpDkZALeVAjmRCw7+OC7RHQWa9k0+bw8HHa8sHo9gOeL6
NlMTOdReJivbPagUvTLrGAMoUgRx5aszPeE4uwc2hGKceeoWMPRfwCvocWvk+QIDAQABo4HwMIHt
MB8GA1UdIwQYMBaAFEjmaPkr0rKV10fYIyAQTzOYkJ/UMB0GA1UdDgQWBBTAephojYn7qwVkDBF9
qn1luMrMTjAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjA6BgNVHR8EMzAxMC+gLaAr
hilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3NlY3VyZWNhLmNybDBOBgNVHSAERzBFMEMG
BFUdIAAwOzA5BggrBgEFBQcCARYtaHR0cHM6Ly93d3cuZ2VvdHJ1c3QuY29tL3Jlc291cmNlcy9y
ZXBvc2l0b3J5MA0GCSqGSIb3DQEBBQUAA4GBAHbhEm5OSxYShjAGsoEIz/AIx8dxfmbuwu3UOx//
8PDITtZDOLC5MH0Y0FWDomrLNhGc6Ehmo21/uBPUR/6LWlxz/K7ZGzIZOKuXNBSqltLroxwUCEm2
u+WR74M26x1Wb8ravHNjkOR/ez4iyz0H7V84dJzjA1BOoa+Y7mHyhD8S
-----END CERTIFICATE-----        
        """ }
      ]
    }
  }
}
{% endhighlight %}

And you should see the request work again.